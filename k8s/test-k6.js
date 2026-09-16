// k6 run test-k6.js

import http from "k6/http";
import { check } from "k6";

export const options = {
    vus: 100,
    duration: "30m",
};

export default function () {
    // const domain = "http://localhost:8888/api";
    const domain = "https://nodepad-be.vulebaolong.com/api";

    const response = http.post(
        `${domain}/auth/login`,
        JSON.stringify({
            email: "admin@gmail.com",
            password: "12345",
        }),
        {
            headers: {
                "Content-Type": "application/json",
            },
        },
    );

    console.log(`Status: ${response.status}`);
    console.log(`Body: ${response.body}`);

    check(response, {
        "status is 200": (res) => res.status === 200,
        "response is JSON": (res) => {
            try {
                res.json();
                return true;
            } catch {
                return false;
            }
        },
    });
}