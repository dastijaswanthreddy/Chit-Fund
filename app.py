from flask import Flask, render_template, request, jsonify
import pickle
import numpy as np

# Flask constructor takes the name of current module (__name__) as argument.
app = Flask(__name__, static_folder='static')

# load the model
model = pickle.load(open('model.pkl', 'rb'))

# function to predict loan approval status
def predict(l): 
    return f'{model.predict(np.array([l]))[0]}'

# define the route for the home page
@app.route('/', methods=['POST', 'GET'])
def home():
    if request.method == 'GET':
        return render_template('register.html')
    
    if request.method == 'POST':
        x1 = request.form['Total_Income']
        x2 = request.form['Total_Family_Members']
        x3 = request.form['Years_of_Working']
        x4 = request.form['Total_Bad_Debt']
        x5 = request.form['Total_Good_Debt']
        try:
            res = predict([int(x1), int(x2), int(x3), int(x4), int(x5)])
            return jsonify({'result': res})
        except Exception as e:
            return jsonify({'error': str(e)})
    
    return render_template('register.html') 

# run the Flask app
if __name__ == '__main__':
    app.run(port=5200)


