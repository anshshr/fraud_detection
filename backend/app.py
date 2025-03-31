from flask import Flask, request, jsonify
from langchain_groq import ChatGroq
from dotenv import load_dotenv
from langchain_core.messages import HumanMessage, SystemMessage
import firebase_admin
from firebase_admin import credentials, db

load_dotenv()

# Initialize Firebase Admin SDK
cred = credentials.Certificate(r"C:\Users\anshs\OneDrive\Documents\projects\Multilingual-Chat-Bot\multilingual_chat_bot\backend\credentials.json")
firebase_admin.initialize_app(cred, {
    "databaseURL": "https://multilingual-chat-app-54d26-default-rtdb.asia-southeast1.firebasedatabase.app/"
})

# Reference to the chat collection
ref = db.reference("/chats")

# Initialize LLM
llm = ChatGroq(
    model="llama-3.1-8b-instant",
    temperature=0,
    max_tokens=None,
    timeout=None,
    max_retries=2,
)

app = Flask(__name__)

@app.route("/chat", methods=["POST"])
def chat():
    data = request.get_json()
    user_input = data.get("message")
    if not user_input:
        return jsonify({"error": "Message is required"}), 400
    
    # Load previous chat history
    chat_history = []
    system_message = SystemMessage("Provide a clear, concise, and language-consistent response that is suitable for text-to-speech applications. Ensure that the response is generated in the same language in which the question is asked.")
    chat_history.append(system_message)
    
    previous_chats = ref.get()
    if previous_chats:
        for msg in previous_chats.values():
            chat_history.append(HumanMessage(msg["user"]))
            chat_history.append(HumanMessage(msg["ai"]))
    
    # Add new user input to history
    human_message = HumanMessage(user_input)
    chat_history.append(human_message)
    
    # Get AI response
    response = llm.invoke(chat_history)
    chat_history.append(response)
    
    # Save conversation to Firebase
    new_chat = ref.push()
    new_chat.set({
        "user": user_input,
        "ai": response.content
    })
    
    return jsonify({"response": response.content})

if __name__ == "__main__":
    app.run(host="0.0.0.0", port=5000, debug=True)

# command to run the program so that it must be accesssible to everyone
# flask run --host=0.0.0.0 --port=5000
