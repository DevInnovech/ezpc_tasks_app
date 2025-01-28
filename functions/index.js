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
    return cors(req, res, async () => {
        // Validar método HTTP
        if (req.method !== 'POST') {
            return res.status(405).json({
                success: false,
                error: 'Method not allowed'
            });
        }

        try {
            const { email, bankDetails } = req.body;

            // Validación mejorada de datos de entrada
            if (!email || !bankDetails) {
                functions.logger.error('Missing required fields:', { email: !!email, bankDetails: !!bankDetails });
                return res.status(400).json({
                    success: false,
                    error: 'Email and bank details are required'
                });
            }

            // Desestructuración y validación de detalles bancarios
            const {
                accountHolderName,
                accountNumber,
                routingNumber,
                bankName,
                accountHolderType = 'individual', // Valor por defecto
                country = 'US',                   // Valor por defecto
                currency = 'usd'                  // Valor por defecto
            } = bankDetails;

            // Validación de campos requeridos
            const requiredFields = {
                accountHolderName,
                accountNumber,
                routingNumber,
                bankName
            };

            const missingFields = Object.entries(requiredFields)
                .filter(([_, value]) => !value)
                .map(([key]) => key);

            if (missingFields.length > 0) {
                functions.logger.error('Missing bank details fields:', missingFields);
                return res.status(400).json({
                    success: false,
                    error: `Missing required fields: ${missingFields.join(', ')}`
                });
            }

            // Buscar o crear cliente usando async/await
            const customer = await stripe.customers.search({
                query: `email:'${email}'`,
                limit: 1
            }).then(result => result.data[0]);

            const customerId = customer
                ? customer.id
                : (await stripe.customers.create({ email })).id;

            functions.logger.info(`Customer ${customer ? 'found' : 'created'}:`, { customerId });

            // Crear cuenta bancaria con manejo de errores mejorado
            const bankAccount = await stripe.customers.createSource(
                customerId,
                {
                    source: {
                        object: 'bank_account',
                        country,
                        currency,
                        account_holder_name: accountHolderName,
                        account_holder_type: accountHolderType,
                        routing_number: routingNumber,
                        account_number: accountNumber
                    }
                }
            );

            functions.logger.info('Bank account added successfully', {
                customerId,
                bankAccountId: bankAccount.id
            });

            return res.status(200).json({
                success: true,
                message: 'Bank account added successfully',
                data: {
                    customerId,
                    bankAccountId: bankAccount.id,
                    lastFour: bankAccount.last4
                }
            });

        } catch (error) {
            functions.logger.error('Error in addBankAccount:', {
                error: error.message,
                stack: error.stack
            });

            // Manejo específico de errores de Stripe
            if (error.type === 'StripeError') {
                return res.status(400).json({
                    success: false,
                    error: error.message,
                    code: error.code
                });
            }

            return res.status(500).json({
                success: false,
                error: 'An internal server error occurred'
            });
        }
    });
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

exports.listBankAccounts = functions.https.onRequest((req, res) => {
  return cors(req, res, async () => {
    try {
      const { email } = req.body;

      if (!email) {
        return res.status(400).json({
          success: false,
          error: 'Email is required.',
        });
      }

      // Buscar el cliente en Stripe
      const customers = await stripe.customers.list({ email, limit: 1 });

      if (customers.data.length === 0) {
        return res.status(404).json({
          success: false,
          error: 'Customer not found.',
        });
      }

      const customerId = customers.data[0].id;

      // Listar fuentes (bank accounts) asociadas al cliente
      const bankAccounts = await stripe.customers.listSources(customerId, {
        object: 'bank_account',
      });

      res.status(200).json({
        success: true,
        bankAccounts: bankAccounts.data.map((account) => ({
          id: account.id,
          bankName: account.bank_name,
          last4: account.last4,
          currency: account.currency,
          country: account.country,
          accountHolderName: account.account_holder_name,
          accountHolderType: account.account_holder_type,
          status: account.status,
        })),
      });
    } catch (error) {
      console.error('Error listing bank accounts:', error);
      res.status(500).json({
        success: false,
        error: error.message,
      });
    }
  });
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

exports.checkrWebhook = functions.https.onRequest(async (req, res) => {
    try {
        if (req.method !== "POST") {
            return res.status(405).send("Method Not Allowed");
        }

        console.log("📩 Webhook recibido de Checkr:", JSON.stringify(req.body, null, 2));

        const eventType = req.body.type;
        const reportData = req.body.data?.object;

        if (!reportData || !reportData.candidate_id) {
            console.error("❌ Error: No se encontró 'candidate_id' en el payload");
            return res.status(400).send("Invalid payload: missing candidate_id");
        }

        const candidateId = reportData.candidate_id;
        const reportId = reportData.id;
        const status = reportData.status || "unknown";
        const result = reportData.result || "unknown";
        const completedAt = reportData.completed_at || null;
        const assessment = reportData.assessment || "not provided";

        console.log(`📝 Procesando candidate_id: ${candidateId}, status: ${status}`);

        // Actualizar Firestore con la información del reporte
        await admin.firestore().collection("background_checks").doc(candidateId).set({
            status: status,
            report_id: reportId,
            completed_at: completedAt,
            result: result,
            assessment: assessment,
            updated_at: admin.firestore.FieldValue.serverTimestamp(),
        }, { merge: true });

        console.log(`✅ Background check actualizado para candidate_id: ${candidateId}`);

        res.status(200).send("✅ Webhook recibido correctamente");
    } catch (error) {
        console.error("❌ Error procesando el webhook:", error);
        res.status(500).send("Error interno del servidor");
    }
});



