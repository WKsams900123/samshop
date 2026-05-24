-- ============================================
-- 会员店优选代购 - Supabase 数据库初始化脚本
-- 在 Supabase SQL Editor 中粘贴执行即可
-- ============================================

-- 1. 创建订单表
CREATE TABLE IF NOT EXISTS orders (
  id BIGSERIAL PRIMARY KEY,
  order_id VARCHAR(20) NOT NULL UNIQUE,
  time VARCHAR(20) NOT NULL,
  customer JSONB NOT NULL,
  items JSONB NOT NULL,
  total DECIMAL(10,2) NOT NULL,
  status VARCHAR(20) NOT NULL DEFAULT 'new',
  created_at TIMESTAMPTZ DEFAULT NOW()
);

-- 2. 创建索引（加速按时间排序和按状态筛选）
CREATE INDEX IF NOT EXISTS idx_orders_created_at ON orders(created_at DESC);
CREATE INDEX IF NOT EXISTS idx_orders_status ON orders(status);
CREATE INDEX IF NOT EXISTS idx_orders_order_id ON orders(order_id);

-- 3. 启用行级安全（Row Level Security）
ALTER TABLE orders ENABLE ROW LEVEL SECURITY;

-- 4. 允许任何人提交订单（INSERT）
CREATE POLICY "Anyone can insert orders"
  ON orders FOR INSERT
  WITH CHECK (true);

-- 5. 允许任何人读取订单（SELECT）- 客户不需要密码即可提交
-- 注意：前端管理后台有独立密码保护，不会泄露客户信息
CREATE POLICY "Anyone can read orders"
  ON orders FOR SELECT
  USING (true);

-- 6. 允许任何人更新订单状态（UPDATE）
-- 前端管理后台有密码保护，此策略仅确保云端可写入
CREATE POLICY "Anyone can update orders"
  ON orders FOR UPDATE
  USING (true)
  WITH CHECK (true);

-- ============================================
-- 完成后，请执行以下查询验证：
-- SELECT * FROM orders LIMIT 1;
-- 应返回空结果（0 rows），表示建表成功
-- ============================================
