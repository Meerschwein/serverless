import http from "k6/http";
import { check } from "k6";

// Define service endpoints
const ORDER_SERVICE_URL = __ENV.ORDER_SERVICE_URL || "http://localhost:8082/orders";

export const options = {
	vus: 10,
	duration: "30s",
	cloud: {
		projectID: 3728541,
		// Test runs with the same name groups test runs together
		name: "Cancel Order Test",
	},
};

export default function () {
	const orderId = __ENV.ORDER_ID; // Pass the order ID to cancel via environment variable

	if (!orderId) {
		throw new Error("Please specify an ORDER_ID as an environment variable.");
	}

	// Cancel the order
	const cancelOrderRes = http.post(
		`${ORDER_SERVICE_URL}/${orderId}/cancel`,
		{},
		{
			headers: { "Content-Type": "application/json" },
		}
	);

	check(cancelOrderRes, { "Order canceled successfully": (res) => res.status === 200 });

	// Verify cancellation
	const orderStateRes = http.get(`${ORDER_SERVICE_URL}/${orderId}`);
	check(orderStateRes, {
		"Order state is CANCELED": (res) => JSON.parse(res.body).orderInfo.state === "CANCELLED",
	});
}
