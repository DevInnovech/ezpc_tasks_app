const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");
const express = require('express');
const bodyParser = require('body-parser');
const cors = require('cors');

admin.initializeApp();

const stripe = require("stripe")("sk_test_51Q42mfP1yXF5VqY3ssNk9Q1GLw63m5UUFpRGmJK6Ok42EdA2oJUwt3dGrQrE1sOFKaweDV0ZMMU2rXZPx1niPUZ7009SI4zwNO");

exports.stripePaymentIntentRequest = functions.https.onRequest(async (req, res) => {
    try {
        let customerId;
        const saveCard = req.body.saveCard || false;

        const customerList = await stripe.customers.list({
            email: req.body.email,
            limit: 1
        });
                
        if (customerList.data.length !== 0) {
            customerId = customerList.data[0].id;
        }
        else {
            const customer = await stripe.customers.create({
                email: req.body.email
            });
            customerId = customer.id;
        }

        const ephemeralKey = await stripe.ephemeralKeys.create(
            { customer: customerId },
            { apiVersion: '2023-10-16' }
        );

        let setupIntent;
        if (saveCard) {
            setupIntent = await stripe.setupIntents.create({
                customer: customerId,
                payment_method_types: ['card'],
            });
        }

        const paymentIntent = await stripe.paymentIntents.create({
            amount: parseInt(req.body.amount),
            currency: 'usd',
            customer: customerId,
            setup_future_usage: saveCard ? 'off_session' : undefined,
            automatic_payment_methods: {
                enabled: true,
            },
        });

        res.status(200).send({
            paymentIntent: paymentIntent.client_secret,
            ephemeralKey: ephemeralKey.secret,
            customer: customerId,
            setupIntent: setupIntent?.client_secret,
            success: true,
        });
        
    } catch (error) {
        res.status(404).send({ success: false, error: error.message });
    }
});

exports.addBankAccount = functions.https.onRequest(async (req, res) => {
    try {
      const { email, userId, country, currency, accountHolderName, accountNumber, routingNumber } = req.body;
  
      if (!email || !userId || !country || !currency || !accountHolderName || !accountNumber) {
        return res.status(400).send({ success: false, error: "Missing required fields." });
      }
  
      // Buscar o crear cliente en Stripe
      let customerId;
      const customerList = await stripe.customers.list({ email, limit: 1 });
  
      if (customerList.data.length > 0) {
        customerId = customerList.data[0].id;
      } else {
        const customer = await stripe.customers.create({
          email,
          metadata: { userId },
        });
        customerId = customer.id;
      }
  
      // Agregar cuenta bancaria al cliente
      const bankAccount = await stripe.customers.createSource(customerId, {
        source: {
          object: "bank_account",
          country,
          currency,
          account_holder_name: accountHolderName,
          account_holder_type: "individual", 
          routing_number: routingNumber, 
          account_number: accountNumber,
        },
      });
  
      res.status(200).send({
        success: true,
        message: "Bank account added successfully.",
        bankAccountId: bankAccount.id,
      });
    } catch (error) {
      console.error("Error adding bank account:", error);
      res.status(500).send({ success: false, error: error.message });
    }
  });

exports.addCard = functions.https.onRequest(async (req, res) => {
  try {
    // Log the received request body for debugging
    console.log("Received request body:", req.body);

    const { email, paymentMethodId } = req.body;

    // Validate incoming data
    if (!email || !paymentMethodId) {
      console.error("Missing email or paymentMethodId");
      return res.status(400).json({
        success: false,
        error: "Email and payment method ID are required.",
      });
    }

    console.log(`Processing card for email: ${email}, PaymentMethodId: ${paymentMethodId}`);

    // Retrieve payment method details for validation
    const paymentMethod = await stripe.paymentMethods.retrieve(paymentMethodId);
    if (!paymentMethod) {
      console.error("Invalid paymentMethodId:", paymentMethodId);
      return res.status(400).json({
        success: false,
        error: "Invalid payment method ID.",
      });
    }

    console.log("Payment method details retrieved successfully");

    // Find or create a Stripe customer
    let customerId;
    const customers = await stripe.customers.list({ email, limit: 1 });

    if (customers.data.length > 0) {
      customerId = customers.data[0].id;
      console.log("Existing customer found:", customerId);
    } else {
      const customer = await stripe.customers.create({ email });
      customerId = customer.id;
      console.log("New customer created:", customerId);
    }

    // Check if the payment method is already attached to another customer
    if (paymentMethod.customer && paymentMethod.customer !== customerId) {
      console.error("Payment method already attached to another customer:", paymentMethod.customer);
      return res.status(400).json({
        success: false,
        error: "Payment method is already attached to another customer.",
      });
    }

    // Attach the payment method to the customer
    await stripe.paymentMethods.attach(paymentMethodId, {
      customer: customerId,
    });

    console.log("Payment method successfully attached to customer:", customerId);

    // Set the payment method as default for invoices
    await stripe.customers.update(customerId, {
      invoice_settings: {
        default_payment_method: paymentMethodId,
      },
    });

    console.log("Payment method set as default for customer:", customerId);

    // Return success response
    return res.status(200).json({
      success: true,
      message: "Card added successfully",
      customerId,
      paymentMethodId,
    });
  } catch (error) {
    // Handle errors gracefully and log for debugging
    console.error("Error processing addCard request:", error);
    return res.status(500).json({
      success: false,
      error: error.message,
    });
  }
});

  
  
exports.listPaymentMethods = functions.https.onRequest(async (req, res) => {
    try {
        const { email } = req.body;

        if (!email) {
            return res.status(400).send({ 
                success: false, 
                error: 'Email is required' 
            });
        }

        // Buscar cliente
        const customers = await stripe.customers.list({
            email: email,
            limit: 1
        });

        if (customers.data.length > 0) {
            const customerId = customers.data[0].id;
            
            const paymentMethods = await stripe.paymentMethods.list({
                customer: customerId,
                type: 'card'
            });

            return res.status(200).send({
                success: true,
                paymentMethods: paymentMethods.data.map(pm => ({
                    id: pm.id,
                    last4: pm.card.last4,
                    brand: pm.card.brand,
                    expMonth: pm.card.exp_month,
                    expYear: pm.card.exp_year
                }))
            });
        }

        return res.status(200).send({ 
            success: true, 
            paymentMethods: [] 
        });

    } catch (error) {
        logger.error('List Payment Methods Error:', error);
        res.status(500).send({ 
            success: false, 
            error: error.message 
        });
    }
});

exports.deletePaymentMethod = functions.https.onRequest(async (req, res) => {
    try {
        const { paymentMethodId } = req.body;

        if (!paymentMethodId) {
            return res.status(400).send({ 
                success: false, 
                error: 'Payment method ID is required' 
            });
        }

        await stripe.paymentMethods.detach(paymentMethodId);

        return res.status(200).send({
            success: true,
            message: 'Payment method deleted successfully'
        });

    } catch (error) {
        logger.error('Delete Payment Method Error:', error);
        res.status(500).send({ 
            success: false, 
            error: error.message 
        });
    }
});