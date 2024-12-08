import http from 'k6/http';
import { check } from 'k6';

// Define service endpoints
const ORDER_SERVICE_URL = __ENV.ORDER_SERVICE_URL || 'http://localhost:8082/orders';

export const options = {
  vus: 10,
  duration: '30s',
  cloud: {
    projectID: 3728541,
    // Test runs with the same name groups test runs together
    name: 'Revise Order Test'
  }
};

export default function () {
  const orderId = __ENV.ORDER_ID; // Pass the order ID to revise via environment variable

  if (!orderId) {
    throw new Error('Please specify an ORDER_ID as an environment variable.');
  }

  const revisedQuantity = 10;
  const menuItemId = '1'; // Use the menu item ID from the initial order creation

  // Revise the order
  const reviseOrderRes = http.post(
    `${ORDER_SERVICE_URL}/${orderId}/revise`,
    JSON.stringify({
      revisedLineItems: [{ quantity: revisedQuantity, menuItemId }],
    }),
    { headers: { 'Content-Type': 'application/json' } }
  );

  check(reviseOrderRes, { 'Order revised successfully': (res) => res.status === 200 });

  // Verify the revision
  const orderStateRes = http.get(`${ORDER_SERVICE_URL}/${orderId}`);
  const responseBody = JSON.parse(orderStateRes.body);
  check(orderStateRes, {
    'Order state is APPROVED': (res) => responseBody.orderInfo.state === 'APPROVED',
    'Order total is updated': (res) =>
      responseBody.orderTotal === (revisedQuantity * parseFloat(__ENV.MENU_ITEM_PRICE)).toFixed(2),
  });
}
