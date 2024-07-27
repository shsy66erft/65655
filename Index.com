<!DOCTYPE html>
<html lang="he">
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>עדכוני ערוץ טלגרם</title>
    <style>
        body {
            font-family: Arial, sans-serif;
            background-color: #f0f0f0;
            color: #333;
            margin: 0;
            padding: 0;
            direction: rtl;
        }
        .container {
            max-width: 800px;
            margin: 50px auto;
            padding: 20px;
            background-color: #fff;
            box-shadow: 0 0 10px rgba(0, 0, 0, 0.1);
            border-radius: 10px;
        }
        h1 {
            text-align: center;
            color: #444;
        }
        .update {
            border-bottom: 1px solid #ddd;
            padding: 10px 0;
            position: relative;
        }
        .update:last-child {
            border-bottom: none;
        }
        .update p {
            margin: 0;
            padding: 10px;
            background-color: #fafafa;
            border-radius: 5px;
            box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
        }
        .timestamp {
            font-size: 0.8em;
            color: #888;
            margin-top: 5px;
        }
    </style>
    <script src="https://cdnjs.cloudflare.com/ajax/libs/dompurify/2.3.0/purify.min.js"></script>
</head>
<body>
    <div class="container">
        <h1>עדכוני ערוץ טלגרם</h1>
        <div id="updates"></div>
    </div>

    <script>
        const botToken = '7340941427:AAFiN2zxW5L22ltUhukamyWu__rjAt9iuMA';
        const chatId = '@Makajajsbot'; // הכנס את שם המשתמש של הבוט שלך כאן
        const url = `https://api.telegram.org/bot${botToken}/getUpdates?offset=-1&timeout=10&allowed_updates=["message"]`;

        async function fetchUpdates() {
            try {
                const response = await fetch(url);
                const data = await response.json();
                console.log('Fetched updates:', data);

                if (data.ok) {
                    const updates = data.result.filter(update => update.message && update.message.chat.username == chatId);
                    updateMessages(updates);
                } else {
                    console.error('Error fetching updates:', data);
                }
            } catch (error) {
                console.error('Error:', error);
            }
        }

        function updateMessages(updates) {
            const updatesDiv = document.getElementById('updates');
            updatesDiv.innerHTML = '';

            updates.forEach(update => {
                const message = update.message;
                if (message && message.text) {
                    const updateDiv = document.createElement('div');
                    updateDiv.className = 'update';

                    const p = document.createElement('p');
                    p.innerHTML = DOMPurify.sanitize(message.text, { ADD_ATTR: ['href', 'target'] });

                    const timestamp = document.createElement('div');
                    timestamp.className = 'timestamp';
                    timestamp.textContent = new Date(message.date * 1000).toLocaleString();

                    updateDiv.appendChild(p);
                    updateDiv.appendChild(timestamp);

                    updatesDiv.appendChild(updateDiv);
                }
            });
        }

        // Fetch updates every 10 seconds
        setInterval(fetchUpdates, 10000);

        // Initial fetch
        fetchUpdates();
    </script>
</body>
</html>
