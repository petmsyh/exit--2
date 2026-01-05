import os
from flask import Flask, request, jsonify
from flask_cors import CORS
from telegram import Bot
from telegram.error import TelegramError
from dotenv import load_dotenv
import asyncio

# Load environment variables
load_dotenv()

app = Flask(__name__)
CORS(app)

# Configuration from environment variables
TELEGRAM_BOT_TOKEN = os.getenv('TELEGRAM_BOT_TOKEN')
TELEGRAM_CHANNEL_ID = os.getenv('TELEGRAM_CHANNEL_ID')

if not TELEGRAM_BOT_TOKEN or not TELEGRAM_CHANNEL_ID:
    raise ValueError("TELEGRAM_BOT_TOKEN and TELEGRAM_CHANNEL_ID must be set in .env file")

# Initialize Telegram Bot
bot = Bot(token=TELEGRAM_BOT_TOKEN)

@app.route('/health', methods=['GET'])
def health_check():
    """Health check endpoint"""
    return jsonify({'status': 'healthy'}), 200

@app.route('/upload', methods=['POST'])
def upload_file():
    """Upload file to Telegram channel"""
    try:
        # Check if file is present in request
        if 'file' not in request.files:
            return jsonify({'error': 'No file provided'}), 400
        
        file = request.files['file']
        
        if file.filename == '':
            return jsonify({'error': 'No file selected'}), 400
        
        # Save file temporarily
        temp_path = f'/tmp/{file.filename}'
        file.save(temp_path)
        
        try:
            # Upload to Telegram
            file_size = os.path.getsize(temp_path)
            
            # Run async upload in sync context
            loop = asyncio.new_event_loop()
            asyncio.set_event_loop(loop)
            
            with open(temp_path, 'rb') as f:
                message = loop.run_until_complete(
                    bot.send_document(
                        chat_id=TELEGRAM_CHANNEL_ID,
                        document=f,
                        filename=file.filename
                    )
                )
            
            loop.close()
            
            # Get file information
            telegram_file_id = message.document.file_id
            
            # Generate file URL (via Telegram API)
            file_url = f"https://t.me/c/{TELEGRAM_CHANNEL_ID.replace('-100', '')}/{message.message_id}"
            
            # Clean up temporary file
            os.remove(temp_path)
            
            return jsonify({
                'success': True,
                'telegram_file_id': telegram_file_id,
                'file_url': file_url,
                'file_size': file_size,
                'message_id': message.message_id
            }), 200
            
        except TelegramError as e:
            # Clean up temporary file
            if os.path.exists(temp_path):
                os.remove(temp_path)
            return jsonify({'error': f'Telegram upload failed: {str(e)}'}), 500
            
    except Exception as e:
        return jsonify({'error': f'Upload failed: {str(e)}'}), 500

@app.route('/delete/<message_id>', methods=['DELETE'])
def delete_file(message_id):
    """Delete file from Telegram channel"""
    try:
        loop = asyncio.new_event_loop()
        asyncio.set_event_loop(loop)
        
        loop.run_until_complete(
            bot.delete_message(
                chat_id=TELEGRAM_CHANNEL_ID,
                message_id=int(message_id)
            )
        )
        
        loop.close()
        
        return jsonify({'success': True, 'message': 'File deleted'}), 200
        
    except TelegramError as e:
        return jsonify({'error': f'Telegram delete failed: {str(e)}'}), 500
    except Exception as e:
        return jsonify({'error': f'Delete failed: {str(e)}'}), 500

if __name__ == '__main__':
    # Run Flask app
    app.run(host='0.0.0.0', port=5000, debug=True)
