const functions = require('firebase-functions');
const admin = require('firebase-admin');
const {onRequest} = require("firebase-functions/v2/https");
const logger = require("firebase-functions/logger");

admin.initializeApp();

const stripe = require("stripe")("sk_test_51Q42mfP1yXF5VqY3ssNk9Q1GLw63m5UUFpRGmJK6Ok42EdA2oJUwt3dGrQrE1sOFKaweDV0ZMMU2rXZPx1niPUZ7009SI4zwNO");

exports.stripePaymentIntentRequest = functions.https.onRequest(async (req, res) => {
    try {
        let customerId;
        const saveCard = req.body.saveCard === true;

        //Gets the customer who's email id matches the one sent by the client
        const customerList = await stripe.customers.list({
            email: req.body.email,
            limit: 1
        });
                
        //Checks the if the customer exists, if not creates a new customer
        if (customerList.data.length !== 0) {
            customerId = customerList.data[0].id;
        }
        else {
            const customer = await stripe.customers.create({
                email: req.body.email
            });
            customerId = customer.id;
        }

        //Creates a temporary secret key linked with the customer 
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

        //Creates a new payment intent with amount passed in from the client
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

exports.addCard = functions.https.onRequest(async (req, res) => {
    try {
        const { email, cardDetails } = req.body;

        if (!email || !cardDetails) {
            return res.status(400).send({ success: false, error: 'Email and card details are required' });
        }

        // Buscar cliente en Stripe
        const customers = await stripe.customers.list({
            email: email,
            limit: 1,
        });

        let customerId;
        if (customers.data.length > 0) {
            customerId = customers.data[0].id;
        } else {
            // Crear un nuevo cliente si no existe
            const customer = await stripe.customers.create({ email });
            customerId = customer.id;
        }

        // Crear un token para la tarjeta
        const token = await stripe.tokens.create({
            card: {
                number: cardDetails.number,
                exp_month: cardDetails.expMonth,
                exp_year: cardDetails.expYear,
                cvc: cardDetails.cvc,
            },
        });

        // Agregar la tarjeta al cliente
        const paymentMethod = await stripe.paymentMethods.create({
            type: 'card',
            card: {
                token: token.id,
            },
        });

        // Asociar el método de pago con el cliente
        await stripe.paymentMethods.attach(paymentMethod.id, {
            customer: customerId,
        });

        res.status(200).send({
            success: true,
            message: 'Card added successfully',
            paymentMethodId: paymentMethod.id,
        });
    } catch (error) {
        console.error('Error adding card:', error);
        res.status(500).send({ success: false, error: error.message });
    }
});



// Nueva función para listar métodos de pago guardados
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
            
            // Obtener métodos de pago del cliente
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

// Nueva función para eliminar método de pago
exports.deletePaymentMethod = functions.https.onRequest(async (req, res) => {
    try {
        const { paymentMethodId } = req.body;

        if (!paymentMethodId) {
            return res.status(400).send({ 
                success: false, 
                error: 'Payment method ID is required' 
            });
        }

        // Eliminar método de pago
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