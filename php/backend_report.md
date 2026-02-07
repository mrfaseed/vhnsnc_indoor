# Backend Update Guide

## 1. Create Payments Table
Run this SQL in your database to fetch Payment History:
```sql
CREATE TABLE IF NOT EXISTS payments (
    id INT AUTO_INCREMENT PRIMARY KEY,
    user_id INT NOT NULL,
    amount DECIMAL(10, 2) NOT NULL,
    description VARCHAR(255) NOT NULL,
    payment_status VARCHAR(20) DEFAULT 'success',
    payment_date TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (user_id) REFERENCES users(id) ON DELETE CASCADE
);

-- Optional: Insert dummy data
INSERT INTO payments (user_id, amount, description, payment_status) 
VALUES (1, 499.00, 'Monthly Membership', 'success');
```

## 2. Move New PHP File
Copy the new file to your server:
1.  Source: `Vhnsnc_indoor\php\get_payment_history.php`
2.  Destination: `htdocs\vhnsnc_indoor\get_payment_history.php`

Now `PaymentHistoryScreen` will show real transactions! 💸
