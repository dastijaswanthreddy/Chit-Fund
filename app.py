from flask import Flask, render_template, request, jsonify
import pandas as pd
import pickle

# Flask constructor takes the name of current module (__name__) as argument.
app = Flask(__name__, static_folder='static')

# load the model
model = pickle.load(open('model.pkl', 'rb'))

# define the route for the home page
@app.route('/', methods=['POST', 'GET'])
def home():
    if request.method == 'GET':
        return render_template('credit_approval.html')

    if request.method == 'POST':
        features = [int(x) for x in request.form.values()]
        df = pd.DataFrame([features], columns=['Total_Income', 'Family_Status', 'Job_Title', 'Total_Children', 'Applicant_Age', 'Years_of_Working', 'Total_Bad_Debt','Total_Good_Debt','Owned_Phone','Income_Type'])
        prediction = model.predict(df)
        res = int(prediction[0])
        return jsonify({'result': res})
    return render_template('credit_approval.html')

# run the Flask app
if __name__ == '__main__':
    app.run(port=5200,)


