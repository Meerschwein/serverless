import http from "k6/http";
import { check } from "k6";

// Define service endpoints
const KITCHEN_SERVICE_URL = __ENV.KITCHEN_SERVICE_URL || "http://localhost:8083/tickets";

export const options = {
	vus: 10,
	duration: "30s",
	cloud: {
		projectID: 3728541,
		// Test runs with the same name groups test runs together
		name: "Accept Ticket Test",
	},
};

export default function () {
	const orderId = __ENV.ORDER_ID; // Pass the order ID whose ticket to accept via environment variable

	if (!orderId) {
		throw new Error("Please specify an ORDER_ID as an environment variable.");
	}

	const ticketAcceptanceTime = new Date();
	ticketAcceptanceTime.setHours(ticketAcceptanceTime.getHours() + 9); // Add 9 hours

	// Accept the ticket
	const acceptTicketRes = http.post(
		`${KITCHEN_SERVICE_URL}/${orderId}/accept`,
		JSON.stringify({ readyBy: ticketAcceptanceTime.toISOString() }),
		{ headers: { "Content-Type": "application/json" } }
	);

	check(acceptTicketRes, { "Ticket accepted successfully": (res) => res.status === 200 });

	// Verify the ticket acceptance
	const ticketStateRes = http.get(`${KITCHEN_SERVICE_URL}/${orderId}`);
	const responseBody = JSON.parse(ticketStateRes.body);
	check(ticketStateRes, {
		"Ticket is accepted": (res) => responseBody.ticketStatus === "ACCEPTED",
	});
}
