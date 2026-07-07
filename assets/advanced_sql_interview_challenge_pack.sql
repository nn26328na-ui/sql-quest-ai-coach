PRAGMA foreign_keys = ON;

DROP TABLE IF EXISTS challenge_tags;
DROP TABLE IF EXISTS challenges;
DROP TABLE IF EXISTS chapters;
DROP TABLE IF EXISTS support_tickets;
DROP TABLE IF EXISTS experiments;
DROP TABLE IF EXISTS inventory_snapshots;
DROP TABLE IF EXISTS employees;
DROP TABLE IF EXISTS subscriptions;
DROP TABLE IF EXISTS events;
DROP TABLE IF EXISTS payments;
DROP TABLE IF EXISTS order_items;
DROP TABLE IF EXISTS orders;
DROP TABLE IF EXISTS customer_region_history;
DROP TABLE IF EXISTS products;
DROP TABLE IF EXISTS customers;

CREATE TABLE chapters (
  chapter_id INTEGER PRIMARY KEY,
  title TEXT NOT NULL,
  focus TEXT NOT NULL,
  order_index INTEGER NOT NULL
);

CREATE TABLE challenges (
  challenge_id INTEGER PRIMARY KEY,
  chapter_id INTEGER NOT NULL,
  slug TEXT NOT NULL UNIQUE,
  title TEXT NOT NULL,
  difficulty INTEGER NOT NULL CHECK (difficulty BETWEEN 1 AND 5),
  interview_signal TEXT NOT NULL,
  prompt TEXT NOT NULL,
  schema_focus TEXT NOT NULL,
  starter_sql TEXT NOT NULL,
  expected_query TEXT NOT NULL,
  check_mode TEXT NOT NULL DEFAULT 'result_match',
  hint_1 TEXT NOT NULL,
  hint_2 TEXT NOT NULL,
  explanation TEXT NOT NULL,
  estimated_minutes INTEGER NOT NULL DEFAULT 8,
  xp INTEGER NOT NULL DEFAULT 30,
  FOREIGN KEY (chapter_id) REFERENCES chapters(chapter_id)
);

CREATE TABLE challenge_tags (
  challenge_id INTEGER NOT NULL,
  tag TEXT NOT NULL,
  PRIMARY KEY (challenge_id, tag),
  FOREIGN KEY (challenge_id) REFERENCES challenges(challenge_id)
);

CREATE TABLE customers (
  customer_id INTEGER PRIMARY KEY,
  customer_name TEXT NOT NULL,
  signup_date TEXT NOT NULL,
  region TEXT NOT NULL,
  segment TEXT NOT NULL,
  acquisition_channel TEXT NOT NULL
);

CREATE TABLE customer_region_history (
  history_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  region TEXT NOT NULL,
  valid_from TEXT NOT NULL,
  valid_to TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE products (
  product_id INTEGER PRIMARY KEY,
  category TEXT NOT NULL,
  sku TEXT NOT NULL UNIQUE,
  product_name TEXT NOT NULL,
  list_price REAL NOT NULL
);

CREATE TABLE orders (
  order_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  order_ts TEXT NOT NULL,
  status TEXT NOT NULL,
  coupon_code TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE order_items (
  order_item_id INTEGER PRIMARY KEY,
  order_id INTEGER NOT NULL,
  product_id INTEGER NOT NULL,
  quantity INTEGER NOT NULL,
  unit_price REAL NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE payments (
  payment_id INTEGER PRIMARY KEY,
  order_id INTEGER NOT NULL,
  paid_ts TEXT NOT NULL,
  amount REAL NOT NULL,
  method TEXT NOT NULL,
  status TEXT NOT NULL,
  FOREIGN KEY (order_id) REFERENCES orders(order_id)
);

CREATE TABLE events (
  event_id INTEGER PRIMARY KEY,
  customer_id INTEGER,
  event_ts TEXT NOT NULL,
  session_id TEXT NOT NULL,
  event_name TEXT NOT NULL,
  device TEXT NOT NULL,
  page TEXT NOT NULL,
  campaign TEXT,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE subscriptions (
  subscription_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  plan TEXT NOT NULL,
  start_date TEXT NOT NULL,
  end_date TEXT,
  mrr REAL NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE employees (
  employee_id INTEGER PRIMARY KEY,
  employee_name TEXT NOT NULL,
  manager_id INTEGER,
  department TEXT NOT NULL,
  hire_date TEXT NOT NULL,
  salary REAL NOT NULL,
  FOREIGN KEY (manager_id) REFERENCES employees(employee_id)
);

CREATE TABLE inventory_snapshots (
  snapshot_date TEXT NOT NULL,
  product_id INTEGER NOT NULL,
  warehouse_id INTEGER NOT NULL,
  on_hand INTEGER NOT NULL,
  reserved INTEGER NOT NULL,
  PRIMARY KEY (snapshot_date, product_id, warehouse_id),
  FOREIGN KEY (product_id) REFERENCES products(product_id)
);

CREATE TABLE experiments (
  assignment_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  experiment_name TEXT NOT NULL,
  variant TEXT NOT NULL,
  assigned_at TEXT NOT NULL,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

CREATE TABLE support_tickets (
  ticket_id INTEGER PRIMARY KEY,
  customer_id INTEGER NOT NULL,
  created_at TEXT NOT NULL,
  first_response_at TEXT,
  resolved_at TEXT,
  priority TEXT NOT NULL,
  channel TEXT NOT NULL,
  satisfaction_score INTEGER,
  FOREIGN KEY (customer_id) REFERENCES customers(customer_id)
);

INSERT INTO chapters VALUES
(1, 'Window Functions 深水区', '排名、滑窗、去重、Gaps and Islands', 1),
(2, '业务分析 SQL', '留存、漏斗、复购、RFM、实验分析', 2),
(3, '复杂 JOIN 与数据建模', 'SCD、反连接、半连接、重复事实、口径对齐', 3),
(4, '递归 CTE 与层级问题', '组织树、路径、层级汇总、日期补齐', 4),
(5, '数据质量与对账', '异常检测、审计、幂等、边界口径', 5),
(6, '性能与工程化 SQL', '索引、可维护查询、增量计算、面试解释力', 6);

INSERT INTO customers VALUES
(1, 'Ada Chen', '2025-01-03', 'East', 'SMB', 'organic'),
(2, 'Ben Wang', '2025-01-05', 'North', 'Enterprise', 'paid_search'),
(3, 'Cora Li', '2025-01-20', 'South', 'SMB', 'referral'),
(4, 'Dylan Xu', '2025-02-02', 'East', 'MidMarket', 'organic'),
(5, 'Eva Zhao', '2025-02-10', 'West', 'SMB', 'social'),
(6, 'Finn Liu', '2025-02-11', 'North', 'Enterprise', 'partner'),
(7, 'Gina Ma', '2025-03-01', 'South', 'MidMarket', 'paid_search'),
(8, 'Hank Sun', '2025-03-05', 'East', 'SMB', 'organic'),
(9, 'Iris Hu', '2025-03-18', 'West', 'Enterprise', 'referral'),
(10, 'Jay Tang', '2025-04-01', 'North', 'SMB', 'social'),
(11, 'Kira Guo', '2025-04-04', 'East', 'MidMarket', 'partner'),
(12, 'Leo Fan', '2025-04-18', 'South', 'SMB', 'organic'),
(13, 'Mina Qiu', '2025-05-02', 'West', 'MidMarket', 'paid_search'),
(14, 'Noah Ye', '2025-05-08', 'North', 'SMB', 'referral'),
(15, 'Owen He', '2025-05-20', 'East', 'Enterprise', 'partner');

INSERT INTO customer_region_history VALUES
(1, 1, 'East', '2025-01-03', NULL),
(2, 2, 'North', '2025-01-05', '2025-04-30'),
(3, 2, 'East', '2025-05-01', NULL),
(4, 3, 'South', '2025-01-20', NULL),
(5, 4, 'East', '2025-02-02', NULL),
(6, 5, 'West', '2025-02-10', NULL),
(7, 6, 'North', '2025-02-11', NULL),
(8, 7, 'South', '2025-03-01', '2025-05-15'),
(9, 7, 'West', '2025-05-16', NULL),
(10, 8, 'East', '2025-03-05', NULL),
(11, 9, 'West', '2025-03-18', NULL),
(12, 10, 'North', '2025-04-01', NULL),
(13, 11, 'East', '2025-04-04', NULL),
(14, 12, 'South', '2025-04-18', NULL),
(15, 13, 'West', '2025-05-02', NULL),
(16, 14, 'North', '2025-05-08', NULL),
(17, 15, 'East', '2025-05-20', NULL);

INSERT INTO products VALUES
(101, 'Database', 'DB-PRO', 'SQL Pro Course', 299.00),
(102, 'Database', 'DB-MOCK', 'SQL Mock Interview', 199.00),
(103, 'Analytics', 'AN-DASH', 'Analytics Dashboard Kit', 249.00),
(104, 'Analytics', 'AN-RET', 'Retention Playbook', 149.00),
(105, 'Cloud', 'CL-SANDBOX', 'Cloud SQL Sandbox', 399.00),
(106, 'Cloud', 'CL-OPT', 'Query Optimization Lab', 499.00),
(107, 'Career', 'CA-RESUME', 'Data Resume Review', 99.00),
(108, 'Career', 'CA-MENTOR', 'Senior Engineer Mentor Call', 599.00);

INSERT INTO orders VALUES
(1001, 1, '2025-01-05 10:04:00', 'paid', NULL),
(1002, 2, '2025-01-12 14:10:00', 'paid', 'NEWYEAR'),
(1003, 1, '2025-01-20 09:12:00', 'refunded', NULL),
(1004, 3, '2025-02-01 18:30:00', 'paid', NULL),
(1005, 4, '2025-02-11 11:02:00', 'paid', 'FEB10'),
(1006, 5, '2025-02-15 20:18:00', 'cancelled', NULL),
(1007, 6, '2025-02-20 08:40:00', 'paid', NULL),
(1008, 2, '2025-03-01 17:33:00', 'paid', NULL),
(1009, 7, '2025-03-08 12:25:00', 'paid', 'SPRING'),
(1010, 8, '2025-03-09 19:55:00', 'paid', NULL),
(1011, 9, '2025-03-22 21:05:00', 'paid', NULL),
(1012, 10, '2025-04-02 07:50:00', 'paid', 'APRIL'),
(1013, 11, '2025-04-10 13:01:00', 'paid', NULL),
(1014, 12, '2025-04-20 16:45:00', 'paid', NULL),
(1015, 13, '2025-05-04 09:20:00', 'paid', 'MAYDAY'),
(1016, 14, '2025-05-15 10:40:00', 'paid', NULL),
(1017, 15, '2025-05-21 22:10:00', 'paid', NULL),
(1018, 3, '2025-05-29 15:38:00', 'paid', NULL),
(1019, 1, '2025-06-01 09:00:00', 'paid', NULL),
(1020, 7, '2025-06-03 12:15:00', 'paid', NULL),
(1021, 8, '2025-06-07 20:15:00', 'paid', 'JUNE'),
(1022, 15, '2025-06-12 14:11:00', 'pending', NULL);

INSERT INTO order_items VALUES
(1, 1001, 101, 1, 299.00),
(2, 1001, 107, 1, 79.00),
(3, 1002, 105, 1, 359.00),
(4, 1002, 106, 1, 449.00),
(5, 1003, 102, 1, 199.00),
(6, 1004, 104, 2, 129.00),
(7, 1005, 101, 1, 269.00),
(8, 1005, 103, 1, 229.00),
(9, 1006, 107, 1, 99.00),
(10, 1007, 108, 1, 599.00),
(11, 1008, 106, 1, 499.00),
(12, 1009, 103, 1, 219.00),
(13, 1009, 104, 1, 139.00),
(14, 1010, 101, 1, 299.00),
(15, 1011, 105, 2, 379.00),
(16, 1012, 102, 1, 179.00),
(17, 1013, 103, 1, 249.00),
(18, 1013, 107, 1, 89.00),
(19, 1014, 101, 1, 299.00),
(20, 1015, 106, 1, 469.00),
(21, 1016, 104, 1, 149.00),
(22, 1017, 108, 1, 599.00),
(23, 1018, 101, 1, 299.00),
(24, 1018, 102, 1, 199.00),
(25, 1019, 105, 1, 399.00),
(26, 1020, 106, 1, 499.00),
(27, 1021, 103, 1, 239.00),
(28, 1021, 104, 1, 129.00),
(29, 1022, 102, 1, 199.00);

INSERT INTO payments VALUES
(1, 1001, '2025-01-05 10:05:00', 378.00, 'card', 'captured'),
(2, 1002, '2025-01-12 14:12:00', 808.00, 'bank_transfer', 'captured'),
(3, 1003, '2025-01-20 09:14:00', 199.00, 'card', 'refunded'),
(4, 1004, '2025-02-01 18:34:00', 258.00, 'wallet', 'captured'),
(5, 1005, '2025-02-11 11:04:00', 498.00, 'card', 'captured'),
(6, 1007, '2025-02-20 08:42:00', 599.00, 'bank_transfer', 'captured'),
(7, 1008, '2025-03-01 17:35:00', 499.00, 'bank_transfer', 'captured'),
(8, 1009, '2025-03-08 12:28:00', 358.00, 'card', 'captured'),
(9, 1010, '2025-03-09 19:58:00', 299.00, 'wallet', 'captured'),
(10, 1011, '2025-03-22 21:10:00', 758.00, 'card', 'captured'),
(11, 1012, '2025-04-02 07:53:00', 179.00, 'wallet', 'captured'),
(12, 1013, '2025-04-10 13:06:00', 338.00, 'card', 'captured'),
(13, 1014, '2025-04-20 16:47:00', 299.00, 'card', 'captured'),
(14, 1015, '2025-05-04 09:24:00', 469.00, 'bank_transfer', 'captured'),
(15, 1016, '2025-05-15 10:45:00', 149.00, 'wallet', 'captured'),
(16, 1017, '2025-05-21 22:14:00', 599.00, 'card', 'captured'),
(17, 1018, '2025-05-29 15:42:00', 498.00, 'card', 'captured'),
(18, 1019, '2025-06-01 09:03:00', 399.00, 'bank_transfer', 'captured'),
(19, 1020, '2025-06-03 12:17:00', 499.00, 'card', 'captured'),
(20, 1021, '2025-06-07 20:18:00', 368.00, 'wallet', 'captured');

INSERT INTO events VALUES
(1, 1, '2025-01-05 09:52:00', 's001', 'view_product', 'ios', '/products/db-pro', 'organic'),
(2, 1, '2025-01-05 09:55:00', 's001', 'add_to_cart', 'ios', '/cart', 'organic'),
(3, 1, '2025-01-05 10:04:00', 's001', 'purchase', 'ios', '/checkout/success', 'organic'),
(4, 2, '2025-01-12 13:50:00', 's002', 'view_product', 'web', '/products/cloud-sql', 'paid_search'),
(5, 2, '2025-01-12 14:00:00', 's002', 'add_to_cart', 'web', '/cart', 'paid_search'),
(6, 2, '2025-01-12 14:10:00', 's002', 'purchase', 'web', '/checkout/success', 'paid_search'),
(7, 3, '2025-02-01 18:00:00', 's003', 'view_product', 'android', '/products/retention', 'referral'),
(8, 3, '2025-02-01 18:20:00', 's003', 'add_to_cart', 'android', '/cart', 'referral'),
(9, 3, '2025-02-01 18:30:00', 's003', 'purchase', 'android', '/checkout/success', 'referral'),
(10, 4, '2025-02-11 10:30:00', 's004', 'view_product', 'web', '/products/db-pro', 'organic'),
(11, 4, '2025-02-11 11:02:00', 's004', 'purchase', 'web', '/checkout/success', 'organic'),
(12, 5, '2025-02-15 19:40:00', 's005', 'view_product', 'ios', '/products/resume', 'social'),
(13, 5, '2025-02-15 20:00:00', 's005', 'add_to_cart', 'ios', '/cart', 'social'),
(14, 6, '2025-02-20 08:10:00', 's006', 'view_product', 'web', '/products/mentor', 'partner'),
(15, 6, '2025-02-20 08:40:00', 's006', 'purchase', 'web', '/checkout/success', 'partner'),
(16, 7, '2025-03-08 12:00:00', 's007', 'view_product', 'android', '/products/dashboard', 'paid_search'),
(17, 7, '2025-03-08 12:05:00', 's007', 'add_to_cart', 'android', '/cart', 'paid_search'),
(18, 7, '2025-03-08 12:25:00', 's007', 'purchase', 'android', '/checkout/success', 'paid_search'),
(19, 8, '2025-03-09 19:30:00', 's008', 'view_product', 'web', '/products/db-pro', 'organic'),
(20, 8, '2025-03-09 19:55:00', 's008', 'purchase', 'web', '/checkout/success', 'organic'),
(21, 1, '2025-06-01 08:30:00', 's009', 'view_product', 'ios', '/products/cloud-sql', 'organic'),
(22, 1, '2025-06-01 08:50:00', 's009', 'add_to_cart', 'ios', '/cart', 'organic'),
(23, 1, '2025-06-01 09:00:00', 's009', 'purchase', 'ios', '/checkout/success', 'organic'),
(24, 7, '2025-06-03 11:50:00', 's010', 'view_product', 'android', '/products/query-optimization', 'paid_search'),
(25, 7, '2025-06-03 12:05:00', 's010', 'add_to_cart', 'android', '/cart', 'paid_search'),
(26, 7, '2025-06-03 12:15:00', 's010', 'purchase', 'android', '/checkout/success', 'paid_search'),
(27, 10, '2025-04-02 07:30:00', 's011', 'view_product', 'ios', '/products/mock-interview', 'social'),
(28, 10, '2025-04-02 07:50:00', 's011', 'purchase', 'ios', '/checkout/success', 'social'),
(29, 11, '2025-04-10 12:20:00', 's012', 'view_product', 'web', '/products/dashboard', 'partner'),
(30, 11, '2025-04-10 13:01:00', 's012', 'purchase', 'web', '/checkout/success', 'partner'),
(31, NULL, '2025-06-10 09:00:00', 'anon01', 'view_product', 'web', '/products/db-pro', 'paid_search'),
(32, NULL, '2025-06-10 09:15:00', 'anon01', 'add_to_cart', 'web', '/cart', 'paid_search'),
(33, NULL, '2025-06-10 09:50:00', 'anon01', 'view_product', 'web', '/products/cloud-sql', 'paid_search');

INSERT INTO subscriptions VALUES
(1, 1, 'Pro', '2025-01-05', NULL, 49.00),
(2, 2, 'Team', '2025-01-12', '2025-04-15', 199.00),
(3, 2, 'Enterprise', '2025-04-16', NULL, 499.00),
(4, 3, 'Pro', '2025-02-01', '2025-05-01', 49.00),
(5, 4, 'Team', '2025-02-11', NULL, 199.00),
(6, 6, 'Enterprise', '2025-02-20', NULL, 499.00),
(7, 7, 'Team', '2025-03-08', NULL, 199.00),
(8, 8, 'Pro', '2025-03-09', NULL, 49.00),
(9, 9, 'Enterprise', '2025-03-22', NULL, 499.00),
(10, 11, 'Team', '2025-04-10', NULL, 199.00),
(11, 15, 'Enterprise', '2025-05-21', NULL, 499.00);

INSERT INTO employees VALUES
(1, 'Rita CEO', NULL, 'Executive', '2019-01-01', 280000),
(2, 'Sam VP Data', 1, 'Data', '2020-03-01', 220000),
(3, 'Tina VP Eng', 1, 'Engineering', '2020-04-01', 230000),
(4, 'Uma Data Manager', 2, 'Data', '2021-02-01', 170000),
(5, 'Vic Analytics Manager', 2, 'Data', '2021-06-01', 165000),
(6, 'Wen Platform Manager', 3, 'Engineering', '2021-01-10', 175000),
(7, 'Xiao SQL Engineer', 4, 'Data', '2022-08-01', 138000),
(8, 'Yara BI Engineer', 4, 'Data', '2022-09-01', 132000),
(9, 'Zane Analytics Engineer', 5, 'Data', '2023-01-15', 128000),
(10, 'Amy Backend Engineer', 6, 'Engineering', '2023-04-01', 145000),
(11, 'Bo SRE', 6, 'Engineering', '2023-05-01', 150000);

INSERT INTO inventory_snapshots VALUES
('2025-06-01', 101, 1, 20, 3),
('2025-06-01', 102, 1, 15, 2),
('2025-06-01', 103, 1, 9, 1),
('2025-06-01', 104, 1, 7, 0),
('2025-06-01', 105, 1, 5, 1),
('2025-06-01', 106, 1, 3, 0),
('2025-06-02', 101, 1, 18, 2),
('2025-06-02', 102, 1, 15, 1),
('2025-06-02', 103, 1, 9, 2),
('2025-06-02', 104, 1, 7, 1),
('2025-06-02', 105, 1, 4, 1),
('2025-06-02', 106, 1, 2, 1),
('2025-06-03', 101, 1, 18, 3),
('2025-06-03', 102, 1, 14, 1),
('2025-06-03', 103, 1, 8, 2),
('2025-06-03', 104, 1, 6, 1),
('2025-06-03', 105, 1, 4, 1),
('2025-06-03', 106, 1, 1, 1),
('2025-06-04', 101, 1, 16, 2),
('2025-06-04', 102, 1, 14, 1),
('2025-06-04', 103, 1, 8, 2),
('2025-06-04', 104, 1, 6, 1),
('2025-06-04', 105, 1, 4, 1),
('2025-06-04', 106, 1, 1, 1);

INSERT INTO experiments VALUES
(1, 1, 'checkout_copy', 'A', '2025-01-01 00:00:00'),
(2, 2, 'checkout_copy', 'B', '2025-01-01 00:00:00'),
(3, 3, 'checkout_copy', 'A', '2025-01-15 00:00:00'),
(4, 4, 'checkout_copy', 'B', '2025-02-01 00:00:00'),
(5, 5, 'checkout_copy', 'A', '2025-02-01 00:00:00'),
(6, 6, 'checkout_copy', 'B', '2025-02-01 00:00:00'),
(7, 7, 'checkout_copy', 'B', '2025-03-01 00:00:00'),
(8, 8, 'checkout_copy', 'A', '2025-03-01 00:00:00'),
(9, 9, 'checkout_copy', 'A', '2025-03-15 00:00:00'),
(10, 10, 'checkout_copy', 'B', '2025-04-01 00:00:00');

INSERT INTO support_tickets VALUES
(1, 1, '2025-01-06 10:00:00', '2025-01-06 10:15:00', '2025-01-06 11:00:00', 'medium', 'chat', 5),
(2, 2, '2025-01-13 09:00:00', '2025-01-13 10:20:00', '2025-01-14 12:00:00', 'high', 'email', 3),
(3, 3, '2025-02-02 13:00:00', '2025-02-02 13:30:00', '2025-02-02 15:20:00', 'low', 'chat', 4),
(4, 6, '2025-02-20 14:00:00', '2025-02-20 14:05:00', '2025-02-21 10:00:00', 'urgent', 'phone', 4),
(5, 7, '2025-03-09 11:00:00', '2025-03-09 11:40:00', NULL, 'high', 'email', NULL),
(6, 9, '2025-03-23 16:30:00', NULL, NULL, 'urgent', 'email', NULL),
(7, 15, '2025-05-22 10:10:00', '2025-05-22 10:13:00', '2025-05-22 10:50:00', 'urgent', 'phone', 5);

INSERT INTO challenges VALUES
(1, 1, 'top_revenue_order_per_customer', '每个客户最高金额订单', 3, '能否正确避免 GROUP BY 取非聚合列陷阱', '找出每个客户金额最高的一笔已支付订单，返回 customer_id、order_id、order_amount、rank_in_customer。并列金额都保留。', 'orders, order_items', 'WITH order_amounts AS (...) SELECT ...', 'WITH order_amounts AS (
  SELECT o.customer_id, o.order_id, SUM(oi.quantity * oi.unit_price) AS order_amount
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status = ''paid''
  GROUP BY o.customer_id, o.order_id
),
ranked AS (
  SELECT *, RANK() OVER (PARTITION BY customer_id ORDER BY order_amount DESC) AS rank_in_customer
  FROM order_amounts
)
SELECT customer_id, order_id, order_amount, rank_in_customer
FROM ranked
WHERE rank_in_customer = 1
ORDER BY customer_id, order_id;', 'result_match', '先把订单金额聚合到订单粒度。', '并列最高要保留，用 RANK 而不是 ROW_NUMBER。', '高级面试常考：先定粒度，再开窗，避免在明细行上直接排名。', 8, 35);

INSERT INTO challenges VALUES
(2, 1, 'running_revenue_by_month', '月累计收入曲线', 3, '能否写出可复用的累计指标', '按月份统计 captured 支付收入，并输出当年累计收入 running_revenue。', 'payments', 'WITH monthly AS (...) SELECT ...', 'WITH monthly AS (
  SELECT substr(paid_ts, 1, 7) AS month, SUM(amount) AS revenue
  FROM payments
  WHERE status = ''captured''
  GROUP BY substr(paid_ts, 1, 7)
)
SELECT month,
       revenue,
       SUM(revenue) OVER (ORDER BY month ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS running_revenue
FROM monthly
ORDER BY month;', 'result_match', '先聚合到 month 粒度。', '累计窗口的 ORDER BY 应该使用 month。', '工程上常用于看 ARR/MRR、GMV、收入爬坡。', 6, 30);

INSERT INTO challenges VALUES
(3, 1, 'repeat_purchase_gap', '复购间隔分析', 4, '能否用 LAG 处理行为序列', '对每个客户的已支付订单，计算与上一笔已支付订单相隔天数。返回 customer_id、order_id、order_date、days_since_prev_paid_order。', 'orders', 'SELECT ... LAG(...) OVER (...)', 'SELECT customer_id,
       order_id,
       date(order_ts) AS order_date,
       CAST(julianday(date(order_ts)) - julianday(LAG(date(order_ts)) OVER (PARTITION BY customer_id ORDER BY order_ts)) AS INTEGER) AS days_since_prev_paid_order
FROM orders
WHERE status = ''paid''
ORDER BY customer_id, order_ts;', 'result_match', 'LAG 取上一行的日期。', '窗口分区是 customer_id，排序是 order_ts。', '复购、回访、续费都需要这种序列思维。', 7, 35);

INSERT INTO challenges VALUES
(4, 1, 'product_category_top2', '每个品类 Top 2 商品', 3, '能否处理组内 Top N', '按已支付订单的销售额，返回每个 category 销售额前 2 的 product_id、product_name、category、revenue、category_rank。', 'products, orders, order_items', 'WITH product_revenue AS (...)', 'WITH product_revenue AS (
  SELECT p.category, p.product_id, p.product_name, SUM(oi.quantity * oi.unit_price) AS revenue
  FROM order_items oi
  JOIN orders o ON o.order_id = oi.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.status = ''paid''
  GROUP BY p.category, p.product_id, p.product_name
),
ranked AS (
  SELECT *, DENSE_RANK() OVER (PARTITION BY category ORDER BY revenue DESC) AS category_rank
  FROM product_revenue
)
SELECT product_id, product_name, category, revenue, category_rank
FROM ranked
WHERE category_rank <= 2
ORDER BY category, category_rank, product_id;', 'result_match', '按商品粒度聚合收入。', 'Top N per group 用窗口函数比相关子查询清晰。', '高级 SQL 面试中，Top N per group 是基础门槛题。', 8, 35);

INSERT INTO challenges VALUES
(5, 1, 'islands_paid_order_months', '连续下单月份岛屿', 5, '能否解决 gaps and islands', '找出每个客户连续有 paid 订单的月份区间，返回 customer_id、start_month、end_month、month_count。', 'orders', 'WITH paid_months AS (...)', 'WITH paid_months AS (
  SELECT DISTINCT customer_id, substr(order_ts, 1, 7) AS month
  FROM orders
  WHERE status = ''paid''
),
numbered AS (
  SELECT customer_id,
         month,
         ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY month) AS rn
  FROM paid_months
),
grouped AS (
  SELECT customer_id,
         month,
         date(month || ''-01'', printf(''-%d months'', rn)) AS island_key
  FROM numbered
)
SELECT customer_id,
       MIN(month) AS start_month,
       MAX(month) AS end_month,
       COUNT(*) AS month_count
FROM grouped
GROUP BY customer_id, island_key
ORDER BY customer_id, start_month;', 'result_match', '连续月份可以用 month - row_number 归组。', 'SQLite 里用 date(month || ''-01'', printf(...)) 构造归组键。', '这是高级面试经典题，考察序列归组而不是简单聚合。', 12, 50);

INSERT INTO challenges VALUES
(6, 1, 'median_payment_by_method', '支付方式收入中位数', 4, '能否在没有 percentile 函数时手写中位数', '计算每种支付方式 captured 支付金额的中位数，返回 method、median_amount。', 'payments', 'WITH ranked AS (...)', 'WITH ranked AS (
  SELECT method,
         amount,
         ROW_NUMBER() OVER (PARTITION BY method ORDER BY amount) AS rn,
         COUNT(*) OVER (PARTITION BY method) AS cnt
  FROM payments
  WHERE status = ''captured''
)
SELECT method, AVG(amount) AS median_amount
FROM ranked
WHERE rn IN ((cnt + 1) / 2, (cnt + 2) / 2)
GROUP BY method
ORDER BY method;', 'result_match', '中位数需要排序位置。', '奇偶数统一可用 (cnt+1)/2 与 (cnt+2)/2。', '面试里这是“没有内置分析函数时怎么补”的代表题。', 10, 45);

INSERT INTO challenges VALUES
(7, 2, 'monthly_cohort_retention', '月 cohort 留存', 5, '能否定义 cohort 并处理相对月份', '以 signup 月为 cohort，统计每个 cohort 在第 0、1、2、3 个月内有 paid 订单的客户数。返回 cohort_month、month_number、active_customers。', 'customers, orders', 'WITH cohort AS (...)', 'WITH cohort AS (
  SELECT customer_id, substr(signup_date, 1, 7) AS cohort_month
  FROM customers
),
activity AS (
  SELECT DISTINCT customer_id, substr(order_ts, 1, 7) AS active_month
  FROM orders
  WHERE status = ''paid''
),
retention AS (
  SELECT c.cohort_month,
         ((CAST(substr(a.active_month, 1, 4) AS INTEGER) - CAST(substr(c.cohort_month, 1, 4) AS INTEGER)) * 12
          + (CAST(substr(a.active_month, 6, 2) AS INTEGER) - CAST(substr(c.cohort_month, 6, 2) AS INTEGER))) AS month_number,
         a.customer_id
  FROM cohort c
  JOIN activity a ON a.customer_id = c.customer_id
)
SELECT cohort_month, month_number, COUNT(DISTINCT customer_id) AS active_customers
FROM retention
WHERE month_number BETWEEN 0 AND 3
GROUP BY cohort_month, month_number
ORDER BY cohort_month, month_number;', 'result_match', 'cohort 是注册月份，不是下单月份。', 'month_number 是活动月和 cohort 月的月份差。', '高级数据岗位非常看重口径定义：cohort、activity、窗口期。', 14, 55);

INSERT INTO challenges VALUES
(8, 2, 'checkout_funnel_conversion', '转化漏斗', 4, '能否避免事件重复导致转化率膨胀', '按 campaign 统计 view_product -> add_to_cart -> purchase 漏斗人数和转化率。每个客户在每个 campaign 下只算一次。', 'events', 'WITH user_campaign AS (...)', 'WITH user_campaign AS (
  SELECT COALESCE(customer_id, -1) AS customer_id,
         campaign,
         MAX(CASE WHEN event_name = ''view_product'' THEN 1 ELSE 0 END) AS viewed,
         MAX(CASE WHEN event_name = ''add_to_cart'' THEN 1 ELSE 0 END) AS added,
         MAX(CASE WHEN event_name = ''purchase'' THEN 1 ELSE 0 END) AS purchased
  FROM events
  GROUP BY COALESCE(customer_id, -1), campaign
)
SELECT campaign,
       SUM(viewed) AS viewers,
       SUM(added) AS adders,
       SUM(purchased) AS purchasers,
       ROUND(1.0 * SUM(added) / NULLIF(SUM(viewed), 0), 4) AS view_to_cart_rate,
       ROUND(1.0 * SUM(purchased) / NULLIF(SUM(added), 0), 4) AS cart_to_purchase_rate
FROM user_campaign
GROUP BY campaign
ORDER BY campaign;', 'result_match', '漏斗先压到用户粒度。', '避免同一用户多次浏览重复贡献。', '漏斗题考的是粒度控制，不只是 CASE WHEN。', 12, 50);

INSERT INTO challenges VALUES
(9, 2, 'rfm_score', 'RFM 客户分层', 5, '能否把业务指标变成可执行分层', '以 2025-06-30 为观察日，计算每个有 paid 订单客户的 recency_days、frequency、monetary，并用 NTILE(3) 分别打分。', 'orders, order_items', 'WITH customer_orders AS (...)', 'WITH customer_orders AS (
  SELECT o.customer_id,
         o.order_id,
         date(o.order_ts) AS order_date,
         SUM(oi.quantity * oi.unit_price) AS order_amount
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status = ''paid''
  GROUP BY o.customer_id, o.order_id, date(o.order_ts)
),
rfm AS (
  SELECT customer_id,
         CAST(julianday(''2025-06-30'') - julianday(MAX(order_date)) AS INTEGER) AS recency_days,
         COUNT(*) AS frequency,
         SUM(order_amount) AS monetary
  FROM customer_orders
  GROUP BY customer_id
)
SELECT customer_id,
       recency_days,
       frequency,
       monetary,
       NTILE(3) OVER (ORDER BY recency_days DESC) AS recency_score,
       NTILE(3) OVER (ORDER BY frequency ASC) AS frequency_score,
       NTILE(3) OVER (ORDER BY monetary ASC) AS monetary_score
FROM rfm
ORDER BY customer_id;', 'result_match', 'R 越近越好，所以排序方向容易错。', '先得到客户粒度的 R/F/M，再打分。', '这题能暴露候选人是否懂业务指标的方向性。', 14, 55);

INSERT INTO challenges VALUES
(10, 2, 'experiment_lift', '实验转化 Lift', 4, '能否处理实验分组与归因窗口', '对 checkout_copy 实验，统计各 variant 的用户数、7 天内 paid 下单用户数、转化率。', 'experiments, orders', 'SELECT e.variant, ...', 'SELECT e.variant,
       COUNT(DISTINCT e.customer_id) AS assigned_customers,
       COUNT(DISTINCT CASE WHEN o.order_id IS NOT NULL THEN e.customer_id END) AS converted_customers,
       ROUND(1.0 * COUNT(DISTINCT CASE WHEN o.order_id IS NOT NULL THEN e.customer_id END) / COUNT(DISTINCT e.customer_id), 4) AS conversion_rate
FROM experiments e
LEFT JOIN orders o
  ON o.customer_id = e.customer_id
 AND o.status = ''paid''
 AND datetime(o.order_ts) >= datetime(e.assigned_at)
 AND datetime(o.order_ts) < datetime(e.assigned_at, ''+7 days'')
WHERE e.experiment_name = ''checkout_copy''
GROUP BY e.variant
ORDER BY e.variant;', 'result_match', '用 LEFT JOIN 保留未转化用户。', '转化订单必须在 assigned_at 之后且 7 天内。', '实验 SQL 的核心是归因窗口和分母不丢。', 10, 45);

INSERT INTO challenges VALUES
(11, 2, 'net_revenue_by_region_asof', '按交易时地区统计收入', 5, '能否正确使用 SCD2 as-of join', '按客户交易发生时所在地区统计 captured 收入，返回 region、revenue。客户地区要按 order_ts 落入 valid_from/valid_to 判断。', 'orders, order_items, customer_region_history', 'SELECT crh.region, ...', 'SELECT crh.region,
       SUM(oi.quantity * oi.unit_price) AS revenue
FROM orders o
JOIN order_items oi ON oi.order_id = o.order_id
JOIN customer_region_history crh
  ON crh.customer_id = o.customer_id
 AND date(o.order_ts) >= date(crh.valid_from)
 AND (crh.valid_to IS NULL OR date(o.order_ts) <= date(crh.valid_to))
WHERE o.status = ''paid''
GROUP BY crh.region
ORDER BY crh.region;', 'result_match', '不要直接用 customers.region。', 'SCD2 join 的右边界要处理 NULL。', '高级工程师必须能说明“当前维度”和“交易时维度”的区别。', 12, 55);

INSERT INTO challenges VALUES
(12, 2, 'subscription_mrr_snapshot', '月末 MRR 快照', 5, '能否按日期快照计算有效订阅', '统计 2025-03-31、2025-04-30、2025-05-31 三个月末的总 MRR。订阅在快照日 start_date <= snapshot_date 且 end_date 为空或 end_date > snapshot_date 时有效。', 'subscriptions', 'WITH snapshots AS (...)', 'WITH snapshots(snapshot_date) AS (
  VALUES (''2025-03-31''), (''2025-04-30''), (''2025-05-31'')
)
SELECT s.snapshot_date,
       SUM(sub.mrr) AS total_mrr
FROM snapshots s
LEFT JOIN subscriptions sub
  ON date(sub.start_date) <= date(s.snapshot_date)
 AND (sub.end_date IS NULL OR date(sub.end_date) > date(s.snapshot_date))
GROUP BY s.snapshot_date
ORDER BY s.snapshot_date;', 'result_match', '快照日需要一个日期维表或临时 CTE。', 'end_date > snapshot_date 表示快照当天仍有效。', '订阅指标常卡在日期边界，面试官很喜欢追问。', 12, 50);

INSERT INTO challenges VALUES
(13, 3, 'anti_join_no_purchase_after_cart', '加购未购买用户', 3, '能否写出稳定的反连接', '找出发生过 add_to_cart 但同一 session 没有 purchase 的 session_id、customer_id、campaign。', 'events', 'SELECT ... WHERE NOT EXISTS (...)', 'SELECT DISTINCT e.session_id, e.customer_id, e.campaign
FROM events e
WHERE e.event_name = ''add_to_cart''
  AND NOT EXISTS (
    SELECT 1
    FROM events p
    WHERE p.session_id = e.session_id
      AND p.event_name = ''purchase''
  )
ORDER BY e.session_id;', 'result_match', '反连接建议优先 NOT EXISTS。', '限定同一 session，而不是同一 customer。', '这题检验你是否能把业务主语从用户切换到会话。', 7, 35);

INSERT INTO challenges VALUES
(14, 3, 'payment_order_reconciliation', '订单支付对账', 4, '能否发现事实表金额不一致', '对每笔 paid 订单比较订单明细金额与 captured 支付金额，返回不一致的 order_id、item_amount、captured_amount、diff_amount。', 'orders, order_items, payments', 'WITH item_amount AS (...)', 'WITH item_amount AS (
  SELECT o.order_id, SUM(oi.quantity * oi.unit_price) AS item_amount
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status = ''paid''
  GROUP BY o.order_id
),
pay_amount AS (
  SELECT order_id, SUM(amount) AS captured_amount
  FROM payments
  WHERE status = ''captured''
  GROUP BY order_id
)
SELECT i.order_id,
       i.item_amount,
       COALESCE(p.captured_amount, 0) AS captured_amount,
       i.item_amount - COALESCE(p.captured_amount, 0) AS diff_amount
FROM item_amount i
LEFT JOIN pay_amount p ON p.order_id = i.order_id
WHERE ABS(i.item_amount - COALESCE(p.captured_amount, 0)) > 0.01
ORDER BY i.order_id;', 'result_match', '先分别聚合，避免明细和支付多对多放大。', '支付缺失也要算异常，所以 LEFT JOIN。', '真实工作里，对账 SQL 比漂亮查询更值钱。', 10, 45);

INSERT INTO challenges VALUES
(15, 3, 'latest_region_snapshot', '当前地区快照', 3, '能否从 SCD2 表取当前记录', '从 customer_region_history 取每个客户当前地区，返回 customer_id、region、valid_from。', 'customer_region_history', 'SELECT ... WHERE valid_to IS NULL', 'SELECT customer_id, region, valid_from
FROM customer_region_history
WHERE valid_to IS NULL
ORDER BY customer_id;', 'result_match', '这个数据模型里当前记录 valid_to 为 NULL。', '如果没有这个约定，再考虑 ROW_NUMBER。', '简单但很实用：先读懂模型约定。', 5, 25);

INSERT INTO challenges VALUES
(16, 3, 'dedupe_latest_event', '事件去重取最后一次', 4, '能否用窗口函数去重并保留整行', '同一 session_id、event_name 可能重复，取每组最后一次事件，返回 event_id、session_id、event_name、event_ts。', 'events', 'WITH ranked AS (...)', 'WITH ranked AS (
  SELECT event_id, session_id, event_name, event_ts,
         ROW_NUMBER() OVER (PARTITION BY session_id, event_name ORDER BY event_ts DESC, event_id DESC) AS rn
  FROM events
)
SELECT event_id, session_id, event_name, event_ts
FROM ranked
WHERE rn = 1
ORDER BY session_id, event_name;', 'result_match', '去重又要保留整行，ROW_NUMBER 很稳。', 'ORDER BY 加 event_id 可处理同时间并列。', '高级面试会追问：为什么不用 GROUP BY max(event_ts) 直接取其他列？', 8, 40);

INSERT INTO challenges VALUES
(17, 3, 'semi_join_buyers_of_category', '买过云产品的客户', 3, '能否区分半连接和普通 JOIN', '返回至少买过一次 Cloud 品类商品的客户 customer_id、customer_name，不能重复。', 'customers, orders, order_items, products', 'SELECT ... WHERE EXISTS (...)', 'SELECT c.customer_id, c.customer_name
FROM customers c
WHERE EXISTS (
  SELECT 1
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.customer_id = c.customer_id
    AND o.status = ''paid''
    AND p.category = ''Cloud''
)
ORDER BY c.customer_id;', 'result_match', '只关心是否存在，用 EXISTS。', 'JOIN 后 DISTINCT 也能做，但意图不如半连接清楚。', '半连接体现 SQL 表达力，也减少重复行风险。', 7, 35);

INSERT INTO challenges VALUES
(18, 3, 'attach_rate_dashboard_retention', '商品搭售率', 4, '能否在订单粒度计算关联购买', '计算购买 Analytics Dashboard Kit 的订单中，同时购买 Retention Playbook 的比例。返回 base_orders、attached_orders、attach_rate。', 'orders, order_items, products', 'WITH order_flags AS (...)', 'WITH order_flags AS (
  SELECT o.order_id,
         MAX(CASE WHEN p.sku = ''AN-DASH'' THEN 1 ELSE 0 END) AS has_dashboard,
         MAX(CASE WHEN p.sku = ''AN-RET'' THEN 1 ELSE 0 END) AS has_retention
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  JOIN products p ON p.product_id = oi.product_id
  WHERE o.status = ''paid''
  GROUP BY o.order_id
)
SELECT SUM(has_dashboard) AS base_orders,
       SUM(CASE WHEN has_dashboard = 1 AND has_retention = 1 THEN 1 ELSE 0 END) AS attached_orders,
       ROUND(1.0 * SUM(CASE WHEN has_dashboard = 1 AND has_retention = 1 THEN 1 ELSE 0 END) / NULLIF(SUM(has_dashboard), 0), 4) AS attach_rate
FROM order_flags;', 'result_match', '先压到订单粒度打 flag。', '分母是购买 Dashboard 的订单数。', '关联购买题常见坑是明细行乘法导致分母膨胀。', 9, 40);

INSERT INTO challenges VALUES
(19, 4, 'employee_org_depth', '员工组织层级深度', 4, '能否写递归 CTE 遍历树', '从 CEO 开始输出每个员工的层级深度 depth 和汇报路径 path。CEO depth=0。', 'employees', 'WITH RECURSIVE org AS (...)', 'WITH RECURSIVE org AS (
  SELECT employee_id, employee_name, manager_id, 0 AS depth, employee_name AS path
  FROM employees
  WHERE manager_id IS NULL
  UNION ALL
  SELECT e.employee_id, e.employee_name, e.manager_id, org.depth + 1,
         org.path || '' > '' || e.employee_name AS path
  FROM employees e
  JOIN org ON e.manager_id = org.employee_id
)
SELECT employee_id, employee_name, manager_id, depth, path
FROM org
ORDER BY path;', 'result_match', '递归 CTE 分 anchor 和 recursive 两部分。', 'path 可以帮助检查树遍历结果。', '递归题能迅速区分“会写查询”和“会建模思考”。', 10, 45);

INSERT INTO challenges VALUES
(20, 4, 'manager_team_salary', '经理团队薪资总额', 5, '能否递归展开下属后做汇总', '对每个经理，统计其所有直接和间接下属人数与薪资总额。返回 manager_id、report_count、report_salary。', 'employees', 'WITH RECURSIVE reports AS (...)', 'WITH RECURSIVE reports AS (
  SELECT manager_id, employee_id AS report_id, salary AS report_salary
  FROM employees
  WHERE manager_id IS NOT NULL
  UNION ALL
  SELECT r.manager_id, e.employee_id AS report_id, e.salary AS report_salary
  FROM reports r
  JOIN employees e ON e.manager_id = r.report_id
)
SELECT manager_id,
       COUNT(DISTINCT report_id) AS report_count,
       SUM(report_salary) AS report_salary
FROM reports
GROUP BY manager_id
ORDER BY manager_id;', 'result_match', '递归表要保留原始 manager_id。', '间接下属通过上一层 report_id 继续展开。', '这是层级汇总，比单纯输出路径更贴近实际业务。', 12, 55);

INSERT INTO challenges VALUES
(21, 4, 'date_spine_revenue_fill', '日期补齐收入', 5, '能否生成日期序列并补零', '生成 2025-06-01 到 2025-06-07 的日期序列，统计每日 captured 收入，没有收入的日期显示 0。', 'payments', 'WITH RECURSIVE dates AS (...)', 'WITH RECURSIVE dates(day) AS (
  SELECT date(''2025-06-01'')
  UNION ALL
  SELECT date(day, ''+1 day'') FROM dates WHERE day < date(''2025-06-07'')
),
daily AS (
  SELECT date(paid_ts) AS day, SUM(amount) AS revenue
  FROM payments
  WHERE status = ''captured''
  GROUP BY date(paid_ts)
)
SELECT dates.day, COALESCE(daily.revenue, 0) AS revenue
FROM dates
LEFT JOIN daily ON daily.day = dates.day
ORDER BY dates.day;', 'result_match', '先生成 date spine。', '补零用 LEFT JOIN + COALESCE。', '报表工程非常常见：不要让缺失日期从图上消失。', 10, 45);

INSERT INTO challenges VALUES
(22, 4, 'inventory_stockout_risk', '连续低库存预警', 4, '能否结合库存快照和窗口判断趋势', '找出 2025-06-01 到 2025-06-04 中可售库存 available = on_hand - reserved 连续下降的商品和日期。返回 product_id、snapshot_date、available、prev_available。', 'inventory_snapshots', 'WITH stock AS (...)', 'WITH stock AS (
  SELECT snapshot_date,
         product_id,
         SUM(on_hand - reserved) AS available
  FROM inventory_snapshots
  GROUP BY snapshot_date, product_id
),
lagged AS (
  SELECT product_id,
         snapshot_date,
         available,
         LAG(available) OVER (PARTITION BY product_id ORDER BY snapshot_date) AS prev_available
  FROM stock
)
SELECT product_id, snapshot_date, available, prev_available
FROM lagged
WHERE prev_available IS NOT NULL
  AND available < prev_available
ORDER BY product_id, snapshot_date;', 'result_match', '先按商品和日期聚合库存。', 'LAG 对比上一天可售库存。', '这题训练把快照表变成趋势信号。', 8, 40);

INSERT INTO challenges VALUES
(23, 5, 'unanswered_urgent_tickets', '未响应紧急工单', 3, '能否准确表达 SLA 异常', '找出 urgent 工单中超过 30 分钟没有 first_response_at，或者至今没有响应的 ticket_id、customer_id、created_at。假设当前时间为 2025-06-01 00:00:00。', 'support_tickets', 'SELECT ...', 'SELECT ticket_id, customer_id, created_at
FROM support_tickets
WHERE priority = ''urgent''
  AND (
    first_response_at IS NULL
    OR (julianday(first_response_at) - julianday(created_at)) * 24 * 60 > 30
  )
ORDER BY ticket_id;', 'result_match', 'NULL 响应要单独处理。', '分钟差可以用 julianday 差值乘 24*60。', 'SLA 异常题看的是边界条件和 NULL 意识。', 7, 35);

INSERT INTO challenges VALUES
(24, 5, 'duplicate_experiment_assignment', '实验重复分组审计', 4, '能否发现实验分配污染', '找出同一 customer_id 在同一 experiment_name 下被分配到多个 variant 的情况，返回 customer_id、experiment_name、variant_count。', 'experiments', 'SELECT ... COUNT(DISTINCT variant)', 'SELECT customer_id,
       experiment_name,
       COUNT(DISTINCT variant) AS variant_count
FROM experiments
GROUP BY customer_id, experiment_name
HAVING COUNT(DISTINCT variant) > 1
ORDER BY customer_id, experiment_name;', 'result_match', '实验污染的核心是 variant_count > 1。', '不要只找重复行，要找不同 variant。', '高级实验分析必须先做数据审计。', 6, 35);

INSERT INTO challenges VALUES
(25, 5, 'orders_missing_captured_payment', '已支付订单缺少入账', 4, '能否用反连接做资金异常', '找出 status=paid 但没有 captured 支付记录的订单。返回 order_id、customer_id、order_ts。', 'orders, payments', 'SELECT ... WHERE NOT EXISTS (...)', 'SELECT o.order_id, o.customer_id, o.order_ts
FROM orders o
WHERE o.status = ''paid''
  AND NOT EXISTS (
    SELECT 1
    FROM payments p
    WHERE p.order_id = o.order_id
      AND p.status = ''captured''
  )
ORDER BY o.order_id;', 'result_match', '用 NOT EXISTS 表达“没有 captured 记录”。', '不要被 refunded 或其他状态支付误导。', '这类题贴近真实数据平台的财务告警。', 7, 40);

INSERT INTO challenges VALUES
(26, 5, 'negative_or_zero_available_inventory', '库存不可售异常', 3, '能否写清楚派生指标条件', '找出任意日期商品仓库可售库存 available = on_hand - reserved 小于等于 0 的记录。返回 snapshot_date、product_id、warehouse_id、available。', 'inventory_snapshots', 'SELECT ...', 'SELECT snapshot_date,
       product_id,
       warehouse_id,
       on_hand - reserved AS available
FROM inventory_snapshots
WHERE on_hand - reserved <= 0
ORDER BY snapshot_date, product_id, warehouse_id;', 'result_match', 'available 是派生列。', '条件里也可以直接写表达式。', '简单但高频：异常检测要定义清楚阈值。', 5, 25);

INSERT INTO challenges VALUES
(27, 5, 'refund_revenue_exclusion', '净收入口径修正', 4, '能否区分订单状态和支付状态口径', '按月统计净收入：captured 支付计正数，refunded 支付计负数。返回 month、net_revenue。', 'payments', 'SELECT ... CASE WHEN ...', 'SELECT substr(paid_ts, 1, 7) AS month,
       SUM(CASE
             WHEN status = ''captured'' THEN amount
             WHEN status = ''refunded'' THEN -amount
             ELSE 0
           END) AS net_revenue
FROM payments
WHERE status IN (''captured'', ''refunded'')
GROUP BY substr(paid_ts, 1, 7)
ORDER BY month;', 'result_match', '退款不是简单过滤掉，而是负向冲减。', '月度收入口径来自支付事实表。', '面试会看你是否能主动问“GMV、收入、净收入”的区别。', 8, 40);

INSERT INTO challenges VALUES
(28, 5, 'event_sequence_violation', '事件顺序异常', 5, '能否验证漏斗事件顺序', '找出同一 session 中 purchase 发生在 add_to_cart 之前，或没有 add_to_cart 却 purchase 的 session_id。', 'events', 'WITH session_times AS (...)', 'WITH session_times AS (
  SELECT session_id,
         MIN(CASE WHEN event_name = ''add_to_cart'' THEN event_ts END) AS first_cart_ts,
         MIN(CASE WHEN event_name = ''purchase'' THEN event_ts END) AS first_purchase_ts
  FROM events
  GROUP BY session_id
)
SELECT session_id
FROM session_times
WHERE first_purchase_ts IS NOT NULL
  AND (first_cart_ts IS NULL OR first_purchase_ts < first_cart_ts)
ORDER BY session_id;', 'result_match', '先把每个 session 的关键事件时间拿出来。', 'purchase 无 cart 也是异常。', '事件顺序审计是埋点治理里的高级实用题。', 9, 45);

INSERT INTO challenges VALUES
(29, 6, 'index_for_order_lookup', '订单查询索引设计', 4, '能否为查询路径设计复合索引', '给下面查询设计一个合适索引：按 customer_id、status 过滤，并按 order_ts 倒序取最近订单。把索引 SQL 写出来。', 'orders', 'CREATE INDEX ...', 'CREATE INDEX idx_orders_customer_status_ts ON orders(customer_id, status, order_ts DESC);', 'manual_review', '等值过滤列通常放在排序列前。', '这个查询需要 customer_id、status、order_ts。', '性能题不只写 SELECT，还要解释索引列顺序。', 6, 35);

INSERT INTO challenges VALUES
(30, 6, 'covering_index_payment_monthly', '支付月报索引思路', 4, '能否说明过滤、分组、覆盖的取舍', '为 payments 月度 captured 收入查询设计索引：WHERE status=''captured'' GROUP BY substr(paid_ts,1,7)。写出一个通用 SQLite 索引方案。', 'payments', 'CREATE INDEX ...', 'CREATE INDEX idx_payments_status_paid_ts ON payments(status, paid_ts);', 'manual_review', '表达式分组不一定完全吃普通索引，但 status 和时间范围会受益。', '如果生产库支持表达式索引，可进一步考虑 substr(paid_ts,1,7)。', '高级工程师要能说明“这个索引解决哪一段成本”。', 8, 40);

INSERT INTO challenges VALUES
(31, 6, 'rewrite_correlated_subquery', '改写相关子查询', 4, '能否把低效查询改成预聚合 JOIN', '用预聚合 JOIN 改写：查询每个客户的 paid 订单数和总订单金额。返回 customer_id、paid_order_count、paid_revenue。', 'customers, orders, order_items', 'WITH customer_paid AS (...)', 'WITH order_amounts AS (
  SELECT o.customer_id,
         o.order_id,
         SUM(oi.quantity * oi.unit_price) AS order_amount
  FROM orders o
  JOIN order_items oi ON oi.order_id = o.order_id
  WHERE o.status = ''paid''
  GROUP BY o.customer_id, o.order_id
),
customer_paid AS (
  SELECT customer_id,
         COUNT(*) AS paid_order_count,
         SUM(order_amount) AS paid_revenue
  FROM order_amounts
  GROUP BY customer_id
)
SELECT c.customer_id,
       COALESCE(cp.paid_order_count, 0) AS paid_order_count,
       COALESCE(cp.paid_revenue, 0) AS paid_revenue
FROM customers c
LEFT JOIN customer_paid cp ON cp.customer_id = c.customer_id
ORDER BY c.customer_id;', 'result_match', '先把订单金额算成订单粒度。', '再聚合到客户粒度并 LEFT JOIN 回客户表。', '这题考察从“能跑”到“可扩展”的查询改写能力。', 10, 45);

INSERT INTO challenges VALUES
(32, 6, 'incremental_daily_revenue_pattern', '增量日报模式', 5, '能否设计可重复跑的汇总 SQL', '写一个可重复执行的 SQLite upsert，把 2025-06-01 到 2025-06-07 的 captured 支付收入写入 daily_revenue(day, revenue)。', 'payments', 'CREATE TABLE IF NOT EXISTS daily_revenue ...', 'CREATE TABLE IF NOT EXISTS daily_revenue (
  day TEXT PRIMARY KEY,
  revenue REAL NOT NULL
);

INSERT INTO daily_revenue(day, revenue)
SELECT date(paid_ts) AS day, SUM(amount) AS revenue
FROM payments
WHERE status = ''captured''
  AND date(paid_ts) BETWEEN date(''2025-06-01'') AND date(''2025-06-07'')
GROUP BY date(paid_ts)
ON CONFLICT(day) DO UPDATE SET revenue = excluded.revenue;', 'manual_review', '目标表 day 需要唯一约束或主键。', '增量重跑要考虑幂等，不能简单 INSERT 追加。', '高级 SQL 工程师面试会考“如何让 SQL 进入生产”。', 12, 55);

INSERT INTO challenge_tags VALUES
(1, 'window'), (1, 'ranking'), (1, 'grain'),
(2, 'window'), (2, 'running-total'),
(3, 'lag'), (3, 'sequence'),
(4, 'top-n'), (4, 'window'),
(5, 'gaps-islands'), (5, 'advanced'),
(6, 'median'), (6, 'window'),
(7, 'cohort'), (7, 'retention'),
(8, 'funnel'), (8, 'grain'),
(9, 'rfm'), (9, 'segmentation'),
(10, 'experiment'), (10, 'attribution'),
(11, 'scd2'), (11, 'asof-join'),
(12, 'snapshot'), (12, 'subscription'),
(13, 'anti-join'), (13, 'session'),
(14, 'reconciliation'), (14, 'finance'),
(15, 'scd2'), (15, 'dimension'),
(16, 'dedupe'), (16, 'row-number'),
(17, 'semi-join'), (17, 'exists'),
(18, 'attach-rate'), (18, 'grain'),
(19, 'recursive-cte'), (19, 'hierarchy'),
(20, 'recursive-cte'), (20, 'rollup'),
(21, 'date-spine'), (21, 'recursive-cte'),
(22, 'inventory'), (22, 'lag'),
(23, 'sla'), (23, 'null'),
(24, 'experiment'), (24, 'audit'),
(25, 'anti-join'), (25, 'finance'),
(26, 'data-quality'), (26, 'inventory'),
(27, 'net-revenue'), (27, 'finance'),
(28, 'event-sequence'), (28, 'data-quality'),
(29, 'index'), (29, 'performance'),
(30, 'index'), (30, 'performance'),
(31, 'query-rewrite'), (31, 'performance'),
(32, 'incremental'), (32, 'upsert');
