const express = require('express');
const cors = require('cors');
const fs = require('fs').promises;
const path = require('path');

const app = express();
const PORT = process.env.PORT || 3000;
const DATA_FILE = path.join(__dirname, 'data', 'shopping-list.json');

// Trust proxy for proper IP detection behind reverse proxies
app.set('trust proxy', 1);

// Store connected clients for real-time updates
const clients = new Set();

// Middleware
app.use(cors());
app.use(express.json());
app.use(express.static('.'));

// Ensure data directory exists
async function ensureDataDirectory() {
    try {
        await fs.mkdir(path.dirname(DATA_FILE), { recursive: true });
    } catch (error) {
        console.error('Error creating data directory:', error);
    }
}

// Read shopping list from file
async function readShoppingList() {
    try {
        await ensureDataDirectory();
        const data = await fs.readFile(DATA_FILE, 'utf8');
        return JSON.parse(data);
    } catch (error) {
        // If file doesn't exist, return empty array
        return [];
    }
}

// Write shopping list to file
async function writeShoppingList(list) {
    try {
        await ensureDataDirectory();
        await fs.writeFile(DATA_FILE, JSON.stringify(list, null, 2));
    } catch (error) {
        console.error('Error writing to file:', error);
        throw error;
    }
}

// Broadcast updates to all connected clients
function broadcastUpdate(type, data) {
    const message = `data: ${JSON.stringify({ type, data, timestamp: new Date().toISOString() })}\n\n`;
    
    clients.forEach(client => {
        try {
            client.write(message);
        } catch (error) {
            console.error('Error sending update to client:', error);
            clients.delete(client);
        }
    });
}

// Routes

// Server-Sent Events endpoint for real-time updates
app.get('/api/events', (req, res) => {
    // Set headers for SSE
    res.writeHead(200, {
        'Content-Type': 'text/event-stream',
        'Cache-Control': 'no-cache',
        'Connection': 'keep-alive',
        'Access-Control-Allow-Origin': '*',
        'Access-Control-Allow-Headers': 'Cache-Control'
    });

    // Send initial connection message
    res.write(`data: ${JSON.stringify({ type: 'connected', timestamp: new Date().toISOString() })}\n\n`);

    // Add client to the set
    clients.add(res);

    // Handle client disconnect
    req.on('close', () => {
        clients.delete(res);
        console.log('Client disconnected from SSE');
    });

    console.log('Client connected to SSE');
});

// Get all items
app.get('/api/items', async (req, res) => {
    try {
        const items = await readShoppingList();
        res.json(items);
    } catch (error) {
        res.status(500).json({ error: 'Failed to read shopping list' });
    }
});

// Add new item
app.post('/api/items', async (req, res) => {
    try {
        const { name, quantity = 1, category = 'Other' } = req.body;
        
        if (!name || name.trim() === '') {
            return res.status(400).json({ error: 'Item name is required' });
        }

        const items = await readShoppingList();
        const newItem = {
            id: Date.now().toString(),
            name: name.trim(),
            quantity: parseInt(quantity) || 1,
            category: category.trim(),
            completed: false,
            createdAt: new Date().toISOString(),
            updatedAt: new Date().toISOString()
        };

        items.push(newItem);
        await writeShoppingList(items);
        
        // Broadcast the new item to all connected clients
        broadcastUpdate('item_added', newItem);
        
        res.status(201).json(newItem);
    } catch (error) {
        res.status(500).json({ error: 'Failed to add item' });
    }
});

// Update item
app.put('/api/items/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const { name, quantity, category, completed } = req.body;
        
        const items = await readShoppingList();
        const itemIndex = items.findIndex(item => item.id === id);
        
        if (itemIndex === -1) {
            return res.status(404).json({ error: 'Item not found' });
        }

        // Update only provided fields
        if (name !== undefined) items[itemIndex].name = name.trim();
        if (quantity !== undefined) items[itemIndex].quantity = parseInt(quantity) || 1;
        if (category !== undefined) items[itemIndex].category = category.trim();
        if (completed !== undefined) items[itemIndex].completed = Boolean(completed);
        
        items[itemIndex].updatedAt = new Date().toISOString();
        
        await writeShoppingList(items);
        
        // Broadcast the updated item to all connected clients
        broadcastUpdate('item_updated', items[itemIndex]);
        
        res.json(items[itemIndex]);
    } catch (error) {
        res.status(500).json({ error: 'Failed to update item' });
    }
});

// Delete item
app.delete('/api/items/:id', async (req, res) => {
    try {
        const { id } = req.params;
        const items = await readShoppingList();
        const itemIndex = items.findIndex(item => item.id === id);
        
        if (itemIndex === -1) {
            return res.status(404).json({ error: 'Item not found' });
        }

        const deletedItem = items.splice(itemIndex, 1)[0];
        await writeShoppingList(items);
        
        // Broadcast the deleted item to all connected clients
        broadcastUpdate('item_deleted', { id, item: deletedItem });
        
        res.json({ message: 'Item deleted successfully', item: deletedItem });
    } catch (error) {
        res.status(500).json({ error: 'Failed to delete item' });
    }
});

// Toggle item completion
app.patch('/api/items/:id/toggle', async (req, res) => {
    try {
        const { id } = req.params;
        const items = await readShoppingList();
        const itemIndex = items.findIndex(item => item.id === id);
        
        if (itemIndex === -1) {
            return res.status(404).json({ error: 'Item not found' });
        }

        items[itemIndex].completed = !items[itemIndex].completed;
        items[itemIndex].updatedAt = new Date().toISOString();
        
        await writeShoppingList(items);
        
        // Broadcast the toggled item to all connected clients
        broadcastUpdate('item_toggled', items[itemIndex]);
        
        res.json(items[itemIndex]);
    } catch (error) {
        res.status(500).json({ error: 'Failed to toggle item' });
    }
});

// Clear all completed items
app.delete('/api/items/clear-completed', async (req, res) => {
    try {
        const items = await readShoppingList();
        const activeItems = items.filter(item => !item.completed);
        
        await writeShoppingList(activeItems);
        
        // Broadcast the clear completed action to all connected clients
        broadcastUpdate('completed_cleared', { remainingCount: activeItems.length });
        
        res.json({ message: 'Completed items cleared', remainingCount: activeItems.length });
    } catch (error) {
        res.status(500).json({ error: 'Failed to clear completed items' });
    }
});

// Serve the main HTML file
app.get('/', (req, res) => {
    res.sendFile(path.join(__dirname, 'index.html'));
});

// Start server
app.listen(PORT, '0.0.0.0', () => {
    console.log(`Supermarket List Server running on port ${PORT}`);
    console.log('Available endpoints:');
    console.log('  GET    /api/items - Get all items');
    console.log('  POST   /api/items - Add new item');
    console.log('  PUT    /api/items/:id - Update item');
    console.log('  DELETE /api/items/:id - Delete item');
    console.log('  PATCH  /api/items/:id/toggle - Toggle item completion');
    console.log('  DELETE /api/items/clear-completed - Clear completed items');
    console.log(`Access your app at: http://localhost:${PORT}`);
});