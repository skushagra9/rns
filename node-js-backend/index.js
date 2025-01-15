const express = require('express');
const { Client } = require('pg');

// Create our Express app
const app = express();

// Parse JSON bodies
app.use(express.json());

// Helper function: create a new PG client using DB_URL environment variable
function getDbClient() {
  const dbUrl = process.env.DB_URL;
  return new Client({
    connectionString: dbUrl,
    ssl: false
  });
}

console.log('DB_URL:', process.env.DB_URL);

/**
 * POST /todos/create
 * Creates a new to-do item. Expects { "task": "some task" } in the request body.
 */
app.post('/todos/create', async (req, res) => {
  const task = req.body.task;
  if (!task) {
    return res.status(400).json({ error: 'Missing "task" field in request body.' });
  }

  const client = getDbClient();
  try {
    await client.connect();

    // Create the table if it doesn't already exist
    await client.query(`
      CREATE TABLE IF NOT EXISTS todos (
        id SERIAL PRIMARY KEY,
        task TEXT NOT NULL
      )
    `);

    // Insert a new record
    const result = await client.query(
      `INSERT INTO todos (task) VALUES ($1) RETURNING id, task`,
      [task]
    );

    // Return the newly created to-do
    const newTodo = result.rows[0];
    return res.status(201).json({
      message: 'To-do created successfully',
      todo: newTodo,
    });
  } catch (error) {
    console.error('Error inserting to-do:', error);
    return res.status(500).json({ error: 'Database error while creating to-do.' });
  } finally {
    await client.end();
  }
});

/**
 * GET /todos
 * Fetches all to-do items.
 */
app.get('/todos', async (req, res) => {
  const client = getDbClient();
  try {
    await client.connect();

    // Query all rows from the "todos" table
    const result = await client.query('SELECT * FROM todos ORDER BY id ASC');

    return res.status(200).json({
      todos: result.rows, // Return the array of todo items
    });
  } catch (error) {
    console.error('Error fetching to-dos:', error);
    return res.status(500).json({ error: 'Database error while fetching to-dos.' });
  } finally {
    await client.end();
  }
});

// Start server on port 8080 (Cloud Run defaults to 8080)
const PORT = process.env.PORT || 8080;
app.listen(PORT, () => {
  console.log(`To-do app listening on port ${PORT}`);
});
