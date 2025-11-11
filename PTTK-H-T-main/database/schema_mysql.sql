-- Tắt kiểm tra khóa ngoại để có thể DROP bảng
SET FOREIGN_KEY_CHECKS = 0;

-- ==========================
-- BẢNG NGƯỜI DÙNG & ĐỊA CHỈ
-- ==========================
DROP TABLE IF EXISTS `users`;
CREATE TABLE
  `users` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `email` VARCHAR(255) NOT NULL UNIQUE COMMENT 'Email đăng nhập (duy nhất)',
    `password_hash` VARCHAR(255) NOT NULL COMMENT 'Mật khẩu đã mã hoá',
    `name` VARCHAR(255) COMMENT 'Tên hiển thị',
    `avatar` VARCHAR(255) COMMENT 'Ảnh đại diện',
    `status` ENUM ('active', 'blocked', 'deleted') DEFAULT 'active' NOT NULL COMMENT 'Trạng thái tài khoản',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP COMMENT 'Ngày tạo'
  ) COMMENT = 'Người dùng hệ thống (khách hàng)';

DROP TABLE IF EXISTS `address`;
CREATE TABLE
  `address` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL COMMENT 'FK -> users.id',
    `line` VARCHAR(255) NOT NULL COMMENT 'Địa chỉ chi tiết (số nhà, đường)',
    `phone` VARCHAR(20) COMMENT 'Số điện thoại liên hệ',
    `ward` VARCHAR(100) COMMENT 'Phường/Xã',
    `district` VARCHAR(100) COMMENT 'Quận/Huyện',
    `province` VARCHAR(100) COMMENT 'Tỉnh/Thành phố',
    `is_default` BOOLEAN DEFAULT FALSE NOT NULL COMMENT 'Có phải địa chỉ mặc định không',
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    INDEX (`user_id`)
  ) COMMENT = 'Địa chỉ giao hàng của khách';

-- ==========================
-- DANH MỤC, THƯƠNG HIỆU, TEMPLATE
-- ==========================
DROP TABLE IF EXISTS `brands`;
CREATE TABLE
  `brands` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL COMMENT 'Tên thương hiệu',
    `slug` VARCHAR(191) NOT NULL UNIQUE COMMENT 'Slug URL duy nhất',
    `image` VARCHAR(255) COMMENT 'Logo hoặc ảnh đại diện',
    `is_active` BOOLEAN DEFAULT TRUE NOT NULL COMMENT 'Có đang hiển thị hay không',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
  ) COMMENT = 'Thương hiệu sản phẩm';

DROP TABLE IF EXISTS `categories`;
CREATE TABLE
  `categories` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL COMMENT 'Tên danh mục',
    `slug` VARCHAR(191) NOT NULL UNIQUE COMMENT 'Slug URL thân thiện',
    `parent_id` INT NULL COMMENT 'Danh mục cha (hỗ trợ phân cấp)',
    `is_active` BOOLEAN DEFAULT TRUE NOT NULL COMMENT 'Có hiển thị hay không',
    `icon_key` VARCHAR(64) COMMENT 'Key icon đại diện',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`parent_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
    INDEX (`parent_id`)
  ) COMMENT = 'Danh mục sản phẩm';

DROP TABLE IF EXISTS `spec_templates`;
CREATE TABLE
  `spec_templates` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `category_id` INT NOT NULL COMMENT 'FK -> categories.id',
    `name` VARCHAR(255) NOT NULL COMMENT 'Tên template',
    `schema_json` JSON NOT NULL COMMENT 'Định nghĩa cấu trúc thông số (JSON)',
    `is_actived` BOOLEAN DEFAULT TRUE NOT NULL COMMENT 'Có phải template đang được áp dụng không',
    `version` INT DEFAULT 1 NOT NULL COMMENT 'Hỗ trợ versioning khi thay đổi template',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE CASCADE,
    INDEX (`category_id`, `is_actived`)
  ) COMMENT = 'Mẫu thông số kỹ thuật của category';

-- ==========================
-- SẢN PHẨM & BIẾN THỂ
-- ==========================
DROP TABLE IF EXISTS `products`;
CREATE TABLE
  `products` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(255) NOT NULL COMMENT 'Tên sản phẩm',
    `slug` VARCHAR(191) NOT NULL UNIQUE COMMENT 'Slug duy nhất',
    `brand_id` INT NOT NULL COMMENT 'FK -> brands.id',
    `category_id` INT NOT NULL COMMENT 'FK -> categories.id',
    `description` TEXT COMMENT 'Mô tả chi tiết',
    `rating_avg` DECIMAL(3, 2) DEFAULT 0.00 NOT NULL COMMENT 'Điểm đánh giá trung bình',
    `rating_count` INT DEFAULT 0 NOT NULL COMMENT 'Số lượt đánh giá',
    `specs_json` JSON COMMENT 'Thông số kỹ thuật chung (JSON)',
    `is_active` BOOLEAN DEFAULT TRUE NOT NULL COMMENT 'Có hiển thị hay không',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`),
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`),
    INDEX (`brand_id`),
    INDEX (`category_id`),
    INDEX (`name`)
  ) COMMENT = 'Sản phẩm chính';

DROP TABLE IF EXISTS `variants`;
CREATE TABLE
  `variants` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `product_id` INT NOT NULL COMMENT 'FK -> products.id',
    `color` VARCHAR(100) COMMENT 'Màu sắc',
    `price` DECIMAL(12, 2) NOT NULL COMMENT 'Giá bán',
    `stock` INT NOT NULL DEFAULT 0 COMMENT 'Tồn kho',
    `specs_json` JSON COMMENT 'Thông số riêng của biến thể',
    `is_active` BOOLEAN DEFAULT TRUE NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
    INDEX (`product_id`),
    INDEX (`price`)
  ) COMMENT = 'Biến thể của sản phẩm';

DROP TABLE IF EXISTS `media`;
CREATE TABLE
  `media` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `variant_id` INT NOT NULL COMMENT 'FK -> variants.id',
    `url` VARCHAR(255) NOT NULL COMMENT 'URL ảnh/video',
    `type` ENUM ('image', 'video') DEFAULT 'image' NOT NULL,
    `is_primary` BOOLEAN DEFAULT FALSE NOT NULL COMMENT 'Ảnh chính',
    `sort_order` INT DEFAULT 0 COMMENT 'Thứ tự sắp xếp',
    FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE CASCADE,
    INDEX (`variant_id`)
  ) COMMENT = 'Media của biến thể sản phẩm';

-- ==========================
-- KHUYẾN MÃI & GIỎ HÀNG
-- ==========================
DROP TABLE IF EXISTS `coupons`;
CREATE TABLE
  `coupons` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `code` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Mã giảm giá',
    `type` ENUM ('fixed', 'percentage') NOT NULL COMMENT 'Loại giảm giá',
    `value` DECIMAL(12, 2) NOT NULL COMMENT 'Giá trị giảm',
    `min_order` DECIMAL(12, 2) DEFAULT 0.00 NOT NULL COMMENT 'Đơn tối thiểu',
    `starts_at` DATETIME COMMENT 'Ngày bắt đầu',
    `ends_at` DATETIME COMMENT 'Ngày kết thúc',
    `usage_limit` INT COMMENT 'Số lượt tối đa',
    `used` INT DEFAULT 0 NOT NULL COMMENT 'Đã dùng',
    `status` ENUM ('active', 'blocked', 'deleted') DEFAULT 'active' NOT NULL,
    `category_id` INT COMMENT 'Giới hạn cho category',
    `brand_id` INT COMMENT 'Giới hạn cho brand',
    FOREIGN KEY (`category_id`) REFERENCES `categories` (`id`) ON DELETE SET NULL,
    FOREIGN KEY (`brand_id`) REFERENCES `brands` (`id`) ON DELETE SET NULL,
    INDEX (`starts_at`),
    INDEX (`ends_at`)
  ) COMMENT = 'Mã giảm giá';

DROP TABLE IF EXISTS `carts`;
CREATE TABLE
  `carts` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL UNIQUE COMMENT 'Mỗi user có 1 giỏ hàng',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `coupon_id` INT NULL COMMENT 'FK -> coupons.id',
    `discount` DECIMAL(12, 2) DEFAULT 0.00 NOT NULL COMMENT 'Số tiền đã giảm',
    FOREIGN KEY (`coupon_id`) REFERENCES `coupons` (`id`) ON DELETE SET NULL,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE
  ) COMMENT = 'Giỏ hàng';

DROP TABLE IF EXISTS `cart_items`;
CREATE TABLE
  `cart_items` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `cart_id` INT NOT NULL COMMENT 'FK -> carts.id',
    `variant_id` INT NOT NULL COMMENT 'FK -> variants.id',
    `quantity` INT NOT NULL CHECK (`quantity` > 0),
    FOREIGN KEY (`cart_id`) REFERENCES `carts` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`),
    UNIQUE KEY `uniq_cart_variant` (`cart_id`, `variant_id`)
  ) COMMENT = 'Sản phẩm trong giỏ hàng';

-- ==========================
-- ĐƠN HÀNG & THANH TOÁN
-- ==========================
DROP TABLE IF EXISTS `orders`;
CREATE TABLE
  `orders` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL COMMENT 'FK -> users.id',
    `code` VARCHAR(50) NOT NULL UNIQUE COMMENT 'Mã đơn hàng',
    `status` ENUM (
      'pending',
      'confirmed',
      'processing',
      'shipped',
      'delivered',
      'completed',
      'cancelled',
      'returned',
      'refunded'
    ) NOT NULL DEFAULT 'pending',
    `payment_method` VARCHAR(50),
    `payment_status` ENUM ('pending', 'paid', 'failed') DEFAULT 'pending' NOT NULL,
    `discount` DECIMAL(12, 2) DEFAULT 0.00 NOT NULL,
    `shipping_fee` DECIMAL(12, 2) DEFAULT 0.00 NOT NULL,
    `subtotal` DECIMAL(12, 2) NOT NULL,
    `total` DECIMAL(12, 2) NOT NULL,
    `address_snapshot` JSON COMMENT 'Địa chỉ giao hàng tại thời điểm đặt',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `paid_at` DATETIME,
    `note` TEXT,
    `shipping_provider` VARCHAR(100),
    `shipping_status` VARCHAR(50),
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`),
    INDEX (`user_id`),
    INDEX (`created_at`)
  ) COMMENT = 'Đơn hàng';

DROP TABLE IF EXISTS `order_items`;
CREATE TABLE
  `order_items` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `order_id` INT NOT NULL COMMENT 'FK -> orders.id',
    `variant_id` INT NOT NULL COMMENT 'FK -> variants.id',
    `price` DECIMAL(12, 2) NOT NULL,
    `quantity` INT NOT NULL CHECK (`quantity` > 0),
    `name_snapshot` VARCHAR(255) NOT NULL COMMENT 'Tên sản phẩm tại thời điểm mua',
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`),
    INDEX (`order_id`)
  ) COMMENT = 'Chi tiết sản phẩm trong đơn';

DROP TABLE IF EXISTS `payment_transactions`;
CREATE TABLE
  `payment_transactions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `order_id` INT NOT NULL COMMENT 'FK -> orders.id',
    `provider` VARCHAR(100) COMMENT 'Tên cổng thanh toán (Momo, VNPAY...)',
    `provider_payment_id` VARCHAR(100) COMMENT 'Mã giao dịch bên thứ ba',
    `amount` DECIMAL(12, 2) NOT NULL,
    `status` ENUM ('pending', 'success', 'failed', 'refunded') DEFAULT 'pending' NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
    INDEX (`order_id`),
    INDEX (`status`)
  ) COMMENT = 'Giao dịch thanh toán';

-- ==========================
-- REVIEW & RMA
-- ==========================
DROP TABLE IF EXISTS `reviews`;
CREATE TABLE
  `reviews` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `user_id` INT NOT NULL COMMENT 'FK -> users.id',
    `product_id` INT NOT NULL COMMENT 'FK -> products.id',
    `stars` INT NOT NULL COMMENT 'Số sao (1-5)',
    `content` TEXT,
    `photos_json` JSON COMMENT 'Ảnh kèm theo',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `is_actived` BOOLEAN DEFAULT TRUE NOT NULL,
    FOREIGN KEY (`user_id`) REFERENCES `users` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`product_id`) REFERENCES `products` (`id`) ON DELETE CASCADE,
    CHECK (`stars` BETWEEN 1 AND 5)
  ) COMMENT = 'Đánh giá sản phẩm';

DROP TABLE IF EXISTS `rmas`;
CREATE TABLE
  `rmas` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `order_id` INT NOT NULL COMMENT 'FK -> orders.id',
    `order_item_id` INT NOT NULL COMMENT 'FK -> order_items.id',
    `type` ENUM ('return', 'exchange', 'warranty') NOT NULL,
    `reason` TEXT,
    `status` ENUM (
      'pending',
      'approved',
      'rejected',
      'completed',
      'cancelled'
    ) DEFAULT 'pending' NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    `evidence_json` JSON COMMENT 'Bằng chứng (ảnh/video)',
    FOREIGN KEY (`order_id`) REFERENCES `orders` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE
  ) COMMENT = 'Yêu cầu đổi trả/bảo hành';

-- ==========================
-- STAFF & QUYỀN
-- ==========================
DROP TABLE IF EXISTS `staffs`;
CREATE TABLE
  `staffs` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `email` VARCHAR(255) NOT NULL UNIQUE,
    `password_hash` VARCHAR(255) NOT NULL,
    `name` VARCHAR(255),
    `avatar` VARCHAR(255),
    `status` ENUM ('active', 'blocked', 'deleted') DEFAULT 'active' NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
  ) COMMENT = 'Nhân viên quản trị';

DROP TABLE IF EXISTS `roles`;
CREATE TABLE
  `roles` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `name` VARCHAR(100) NOT NULL UNIQUE,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
  ) COMMENT = 'Vai trò nhân viên';

DROP TABLE IF EXISTS `staff_roles`;
CREATE TABLE
  `staff_roles` (
    `staff_id` INT NOT NULL,
    `role_id` INT NOT NULL,
    `assigned_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`staff_id`, `role_id`),
    FOREIGN KEY (`staff_id`) REFERENCES `staffs` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE
  ) COMMENT = 'Gán vai trò cho nhân viên';

DROP TABLE IF EXISTS `permissions`;
CREATE TABLE
  `permissions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `key` VARCHAR(100) NOT NULL UNIQUE COMMENT 'Mã định danh quyền',
    `name` VARCHAR(255) NOT NULL COMMENT 'Tên quyền',
    `description` TEXT,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP
  ) COMMENT = 'Quyền hệ thống';

DROP TABLE IF EXISTS `role_permissions`;
CREATE TABLE
  `role_permissions` (
    `role_id` INT NOT NULL,
    `permission_id` INT NOT NULL,
    `granted_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    PRIMARY KEY (`role_id`, `permission_id`),
    FOREIGN KEY (`role_id`) REFERENCES `roles` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`permission_id`) REFERENCES `permissions` (`id`) ON DELETE CASCADE
  ) COMMENT = 'Gán quyền cho vai trò';

-- ==========================
-- KHO & THIẾT BỊ
-- ==========================
DROP TABLE IF EXISTS `inventory_transactions`;
CREATE TABLE
  `inventory_transactions` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `variant_id` INT NOT NULL COMMENT 'FK -> variants.id',
    `type` ENUM (
      'in',
      'out',
      'adjustment',
      'reservation',
      'release'
    ) NOT NULL,
    `quantity` INT NOT NULL,
    `reason` TEXT,
    `reference_json` JSON COMMENT 'Thông tin liên quan (ví dụ đơn hàng)',
    `created_by` INT COMMENT 'FK -> staffs.id',
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`),
    FOREIGN KEY (`created_by`) REFERENCES `staffs` (`id`)
  ) COMMENT = 'Nhật ký giao dịch kho';

DROP TABLE IF EXISTS `devices`;
CREATE TABLE
  `devices` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `variant_id` INT NOT NULL COMMENT 'FK -> variants.id',
    `imei` VARCHAR(20) NOT NULL UNIQUE COMMENT 'IMEI duy nhất',
    `status` ENUM (
      'in_stock',
      'sold',
      'reserved',
      'returned',
      'locked'
    ) DEFAULT 'in_stock' NOT NULL,
    `created_at` DATETIME DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (`variant_id`) REFERENCES `variants` (`id`) ON DELETE RESTRICT
  ) COMMENT = 'Thiết bị vật lý theo IMEI';

DROP TABLE IF EXISTS `order_devices`;
CREATE TABLE
  `order_devices` (
    `id` INT PRIMARY KEY AUTO_INCREMENT,
    `order_item_id` INT NOT NULL COMMENT 'FK -> order_items.id',
    `device_id` INT NOT NULL UNIQUE COMMENT 'FK -> devices.id',
    FOREIGN KEY (`order_item_id`) REFERENCES `order_items` (`id`) ON DELETE CASCADE,
    FOREIGN KEY (`device_id`) REFERENCES `devices` (`id`) ON DELETE RESTRICT
  ) COMMENT = 'Thiết bị gắn với đơn hàng';

-- ==========================
-- INDEXES BỔ SUNG
-- ==========================
ALTER TABLE `users` ADD UNIQUE INDEX `idx_users_email` (`email`);
ALTER TABLE `products` ADD UNIQUE INDEX `idx_products_slug` (`slug`),
ADD INDEX `idx_products_category` (`category_id`),
ADD INDEX `idx_products_brand` (`brand_id`);
ALTER TABLE `categories` ADD UNIQUE INDEX `idx_categories_slug` (`slug`);
ALTER TABLE `brands` ADD UNIQUE INDEX `idx_brands_slug` (`slug`);
ALTER TABLE `coupons` ADD UNIQUE INDEX `idx_coupons_code` (`code`);
ALTER TABLE `orders` ADD INDEX `idx_orders_user` (`user_id`),
ADD INDEX `idx_orders_status` (`status`),
ADD INDEX `idx_orders_created_at` (`created_at`);
ALTER TABLE `reviews` ADD INDEX `idx_reviews_product` (`product_id`),
ADD INDEX `idx_reviews_user` (`user_id`);


-- ==========================
-- DỮ LIỆU MẪU
-- ==========================
INSERT INTO
  `users` (`email`, `password_hash`, `name`, `avatar`)
VALUES
  (
    'alice@example.com',
    'hash123',
    'Alice Nguyễn',
    NULL
  ),
  ('bob@example.com', 'hash456', 'Bob Trần', NULL);

INSERT INTO
  `address` (
    `user_id`,
    `line`,
    `phone`,
    `ward`,
    `district`,
    `province`,
    `is_default`
  )
VALUES
  (
    1,
    '123 Lê Lợi',
    '0909123456',
    'Bến Thành',
    'Quận 1',
    'TP HCM',
    TRUE
  ),
  (
    2,
    '456 Trần Hưng Đạo',
    '0912123456',
    'Phạm Ngũ Lão',
    'Quận 1',
    'TP HCM',
    TRUE
  );

INSERT INTO
  `brands` (`name`, `slug`, `image`)
VALUES
  ('Apple', 'apple', 'apple.png'),
  ('Samsung', 'samsung', 'samsung.png');

INSERT INTO
  `categories` (`name`, `slug`, `parent_id`, `icon_key`)
VALUES
  ('Điện thoại', 'dien-thoai', NULL, 'phone'),
  ('Laptop', 'laptop', NULL, 'laptop');

INSERT INTO
  `spec_templates` (`category_id`, `name`, `schema_json`)
VALUES
  (
    1,
    'Điện thoại cơ bản',
    '{}'
  ),
  (
    2,
    'Laptop cơ bản',
    '{}'
  );

INSERT INTO
  `products` (
    `name`,
    `slug`,
    `brand_id`,
    `category_id`,
    `description`,
    `specs_json`
  )
VALUES
  (
    'iPhone 15 Pro',
    'iphone-15-pro',
    1,
    1,
    'Flagship Apple',
    '{"ram":"8GB","storage":"256GB"}'
  ),
  (
    'Galaxy S23',
    'galaxy-s23',
    2,
    1,
    'Flagship Samsung',
    '{"ram":"8GB","storage":"256GB"}'
  ),
  (
    'MacBook Air M2',
    'macbook-air-m2',
    1,
    2,
    'Laptop Apple M2',
    '{"ram":"16GB","cpu":"M2"}'
  );

INSERT INTO
  `variants` (`product_id`, `color`, `price`, `stock`)
VALUES
  (1, 'Black', 28990000, 10),
  (1, 'Silver', 28990000, 5),
  (2, 'Green', 24990000, 8),
  (3, 'Gray', 26990000, 3);

INSERT INTO
  `media` (`variant_id`, `url`, `type`, `is_primary`)
VALUES
  (1, 'iphone-black.jpg', 'image', TRUE),
  (2, 'iphone-silver.jpg', 'image', TRUE),
  (3, 'galaxy-green.jpg', 'image', TRUE),
  (4, 'macbook-gray.jpg', 'image', TRUE);

INSERT INTO
  `coupons` (
    `code`,
    `type`,
    `value`,
    `min_order`,
    `category_id`,
    `brand_id`
  )
VALUES
  ('SALE10', 'percentage', 10, 10000000, 1, NULL),
  ('APPLE500K', 'fixed', 500000, 5000000, NULL, 1);

INSERT INTO
  `carts` (`user_id`)
VALUES
  (1),
  (2);

INSERT INTO
  `cart_items` (`cart_id`, `variant_id`, `quantity`)
VALUES
  (1, 1, 1),
  (2, 3, 2);

INSERT INTO
  `orders` (
    `user_id`,
    `code`,
    `status`,
    `payment_method`,
    `subtotal`,
    `total`,
    `address_snapshot`
  )
VALUES
  (
    1,
    'ORD001',
    'confirmed',
    'COD',
    28990000,
    28990000,
    '{"line":"123 Lê Lợi","phone":"0909123456"}'
  ),
  (
    2,
    'ORD002',
    'pending',
    'Momo',
    49980000,
    49980000,
    '{"line":"456 Trần Hưng Đạo","phone":"0912123456"}'
  );

INSERT INTO
  `order_items` (
    `order_id`,
    `variant_id`,
    `price`,
    `quantity`,
    `name_snapshot`
  )
VALUES
  (1, 1, 28990000, 1, 'iPhone 15 Pro Black'),
  (2, 3, 24990000, 2, 'Galaxy S23 Green');

-- KHÔI PHỤC LẠI LỆNH INSERT DÙNG LAST_INSERT_ID()
INSERT INTO `orders` (`user_id`, `code`, `status`, `payment_method`, `subtotal`, `total`, `address_snapshot`, `created_at`)
VALUES (
  1,
  'ORDER003',
  'pending',
  'COD',
  28990000,
  28990000,
  '{"line":"123 Lê Lợi","phone":"0909123456"}',
  NOW()
);

-- Thêm item vào đơn vừa tạo (LAST_INSERT_ID() lấy order_id mới)
INSERT INTO `order_items` (`order_id`, `variant_id`, `price`, `quantity`, `name_snapshot`)
VALUES (LAST_INSERT_ID(), 1, 28990000, 1, 'iPhone 15 Pro Black');

-- Ghi giao dịch thanh toán
INSERT INTO `payment_transactions` (`order_id`, `provider`, `provider_payment_id`, `amount`, `status`, `created_at`)
VALUES (LAST_INSERT_ID(), 'COD', 'COD-ORDER002', 28990000, 'pending', NOW());
  
INSERT INTO
  `payment_transactions` (
    `order_id`,
    `provider`,
    `provider_payment_id`,
    `amount`,
    `status`
  )
VALUES
  (1, 'COD', 'COD-001', 28990000, 'pending'),
  (2, 'Momo', 'MOMO-XYZ123', 49980000, 'success');

INSERT INTO
  `reviews` (`user_id`, `product_id`, `stars`, `content`)
VALUES
  (1, 1, 5, 'Quá ngon, rất mượt'),
  (2, 2, 4, 'Mượt mà nhưng hơi nóng');

INSERT INTO
  `rmas` (`order_id`, `order_item_id`, `type`, `reason`)
VALUES
  (2, 2, 'return', 'Máy bị lỗi camera');

INSERT INTO
  `staffs` (`email`, `password_hash`, `name`)
VALUES
  ('admin@example.com', 'hashadmin', 'Admin');

INSERT INTO
  `roles` (`name`)
VALUES
  ('Admin'),
  ('CSKH');

INSERT INTO
  `staff_roles` (`staff_id`, `role_id`)
VALUES
  (1, 1);

INSERT INTO
  `permissions` (`key`, `name`)
VALUES
  ('view_orders', 'Xem đơn hàng'),
  ('edit_products', 'Chỉnh sửa sản phẩm');

INSERT INTO
  `role_permissions` (`role_id`, `permission_id`)
VALUES
  (1, 1),
  (1, 2);

INSERT INTO
  `inventory_transactions` (`variant_id`, `type`, `quantity`, `reason`, `created_by`)
VALUES
  (1, 'in', 10, 'Nhập kho đợt 1', 1),
  (3, 'in', 8, 'Nhập kho đợt 1', 1);

INSERT INTO
  `devices` (`variant_id`, `imei`, `status`)
VALUES
  (1, 'IMEI1234567890', 'sold'),
  (3, 'IMEI0987654321', 'reserved');

INSERT INTO
  `order_devices` (`order_item_id`, `device_id`)
VALUES
  (1, 1);

-- Bật lại kiểm tra khóa ngoại
SET FOREIGN_KEY_CHECKS = 1;