import { Pool } from 'pg';

if (!process.env.DATABASE_URL) {
  throw new Error('Por favor define la variable DATABASE_URL en tu entorno');
}

const pool = new Pool({
  connectionString: process.env.DATABASE_URL,
});
export default pool;