import http from "k6/http";
import { check } from "k6";

// Define service endpoints
const CONSUMER_SERVICE_URL = __ENV.CONSUMER_SERVICE_URL || "http://localhost:8081/consumers";
const RESTAURANT_SERVICE_URL = __ENV.RESTAURANT_SERVICE_URL || "http://localhost:8084/restaurants";
const ORDER_SERVICE_URL = __ENV.ORDER_SERVICE_URL || "http://localhost:8082/orders";
const API_URL = __ENV.API_URL || "http://localhost:8082/consumers";

export const options = {
	vus: 100, // Number of virtual users
	duration: "20m", // Test duration
	cloud: {
		projectID: 3728541,
		// Test runs with the same name groups test runs together
		name: "Create Order Test",
	},
};

export default function () {
	// Step 1: Create a consumer
	const createConsumerRes = http.post(
		API_URL,
		JSON.stringify({
			name: { firstName: "testUserFirst", lastName: "testUserLast" },
		}),
		{ headers: { "Content-Type": "application/json" } }
	);

	check(createConsumerRes, { "Consumer created successfully": (res) => res.status === 200 });
	//   const consumerId = JSON.parse(createConsumerRes.body).consumerId;

	// Step 2: Create a restaurant
	//   const createRestaurantRes = http.post(RESTAURANT_SERVICE_URL, JSON.stringify({
	//     name: 'My Restaurant',
	//     address: { street1: '1 Main Street', city: 'Oakland', state: 'CA', zip: '94611' },
	//     menu: { menuItems: [{ id: '1', name: 'Chicken Vindaloo', price: '12.34' }] },
	//   }), { headers: { 'Content-Type': 'application/json' } });

	//   check(createRestaurantRes, { 'Restaurant created successfully': (res) => res.status === 200 });
	//   const restaurantId = JSON.parse(createRestaurantRes.body).id;

	//   // Step 3: Create an order
	//   const createOrderRes = http.post(ORDER_SERVICE_URL, JSON.stringify({
	//     consumerId,
	//     restaurantId,
	//     deliveryAddress: { street: '9 Amazing View', city: 'Oakland', state: 'CA', zip: '94612' },
	//     lineItems: [{ menuItemId: '1', quantity: 5 }],
	//   }), { headers: { 'Content-Type': 'application/json' } });

	//   check(createOrderRes, { 'Order created successfully': (res) => res.status === 200 });
	//   const orderId = JSON.parse(createOrderRes.body).orderId;

	//   // Verify order state
	//   const orderStateRes = http.get(`${ORDER_SERVICE_URL}/${orderId}`);
	//   check(orderStateRes, {
	//     'Order state is APPROVED': (res) => JSON.parse(res.body).state === 'APPROVED',
	//   });
}
