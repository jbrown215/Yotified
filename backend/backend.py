from flask import Flask, jsonify, request
from flask.ext.api import status
from apns import APNs, Payload
from pymongo import MongoClient
from bson.objectid import ObjectId
from time import strftime

app = Flask(__name__)
apns = APNs(use_sandbox=True, cert_file="cert_file.pem", key_file="key_file.pem")
client = MongoClient()
User = client.app.user
User.drop()
Report = client.app.report
Report.drop()
Account = client.app.account
Account.drop()

afrieder = {
  'name': "Alex Frieder",
  '_id': "6312781242",
  'phone': "6312781242",
  'lat': None,
  'long': None,
  'admin': None,
  'checkedin': False,
  'token': "Uhhhhhhh..?",
}
User.insert_one(afrieder)

afrieder_account = {
  '_id': '6312781242',
  'username': 'afrieder',
  'password': 'password'
}
Account.insert_one(afrieder_account)

blichtma = {
  'name': "Ben Lichtman",
  '_id': "6102466685",
  'phone': "6102466685",
  'lat': None,
  'long': None,
  'admin': True,
  'checkedin': False,
  'token': "Uhhhhhhh..?",
}
User.insert_one(blichtma)

blichtma_account = {
  '_id': '6102466685',
  'username': 'blichtma',
  'password': 'password'
}
Account.insert_one(blichtma_account)

def notify_admins(msg):
  admins = User.find(filter={'admin':True}, projection={"token":True})
  for admin in admins:
    payload = Payload(alert=msg, sound="default", badge=1)
    apns.gateway_server.send_notification(admin['token'], payload)

@app.route('/checkin', methods=['POST'])
def checkin():
  user_id = request.form['_id']
  lat = request.form['lat']
  longg = request.form['long']
  User.update_one({'_id': user_id}, {'$set': {'lat': lat, 'long': longg, 'checkedin': True}})
  return ''

@app.route('/checkout', methods=['POST'])
def checkout():
  user_id = request.form['_id']
  User.update_one({'_id': user_id}, {'$set': {'lat': None, 'long': None, 'checkedin': False}})
  return ''

@app.route('/report', methods=['POST'])
def report():
  user_id = request.form['_id']
  anon = request.form['anon'] in ('true', 'True')
  lat = request.form['lat']
  longg = request.form['long']
  User.update_one({'_id':user_id}, {'$set': {'lat': lat, 'long': longg}})
  name = None if anon else User.find_one({'_id': user_id}, projection={'name':True})['name']
  report = {
    'time': strftime('%I:%M %p'),
    'sender': None if anon else user_id,
    'lat': lat,
    'long': longg,
    'handler': None,
    'data': None
  }
  report_id = Report.insert_one(report).inserted_id
  msg = "A new report has been opened{}!".format('' if anon else ' by {}'.format(name))
  notify_admins(msg)
  return jsonify({'_id': report_id})

@app.route('/lowbatt', methods=['POST'])
def lowbatt():
  user_id = request.form['_id']
  lat = request.form['lat']
  longg = request.form['long']
  User.update_one({'_id':user_id}, {'$set': {'lat': lat, 'long': longg}})
  name = User.find_one({'_id':user_id}, projection={'name':True})['name']
  notify_admins("{} has a low battery.".format(name))
  return ''

@app.route('/reportinfo', methods=['POST'])
def reportinfo():
  report_id = ObjectId(request.form['_id'])
  data = request.form['data']
  Report.update_one({'_id':report_id}, {'$set': {'data': data}})
  time = Report.find_one({'_id': report_id}, projection={'time':True})['time']
  notify_admins("The report opened at {} has been updated.".format(time))
  return ''

@app.route('/roster', methods=['GET'])
def roster():
  keys = ['name', 'phone', 'lat', 'long', 'checkedin', '_id']
  users = User.find(projection=keys)
  return jsonify({'roster': list(users)})

@app.route('/checkedin', methods=['GET'])
def checkedin():
  keys = ['name', 'phone', 'lat', 'long', '_id']
  users = User.find(filter={'checkedin':True}, projection=keys)
  return jsonify({'roster': list(users)})

@app.route('/admins', methods=['GET'])
def admins():
  keys = ['name', 'phone', '_id']
  users = User.find(filter={'admin':True}, projection=keys)
  return jsonify({'admins': list(users)})

@app.route('/reports', methods=['GET'])
def reports():
  keys = ['_id', 'sender', 'handler', 'lat', 'long', 'data', 'time']
  report_list = list(Report.find(projection=keys))
  [report.update(_id=str(report['_id']),name='Report opened at {}'.format(time)) for report in report_list]
  return jsonify({'reports': report_list})

@app.route('/addadmin', methods=['POST'])
def addadmin():
  User.update_one({'_id':request.form['_id']}, {'$set': {'admin': True}})
  return ''

@app.route('/deladmin', methods=['POST'])
def deladmin():
  count = User.count({'admin': True})
  if count == 1:
    return 'You are the only admin. You cannot delete yourself.', status.HTTP_406_NOT_ACCEPTABLE
  User.update_one({'_id': request.form['_id']}, {'$set': {'admin': None}})
  return ''

@app.route('/toggleduty', methods=['POST'])
def toggleduty():
  user_id = request.form['_id']
  count = list(User.find({'admin': True}, limit=2))
  if len(count) == 1 and count[0]['_id'] == user_id:
    return 'You are the only admin. You cannot go off-duty.', status.HTTP_406_NOT_ACCEPTABLE
  admin = User.find_one({'_id': user_id}, projection={'admin':True})['admin']
  User.update_one({'_id': user_id}, {'$set': {'admin': not admin}})
  return ''

@app.route('/handlereport', methods=['POST'])
def handlereport():
  Report.update_one({'_id': ObjectId(request.form['_id'])}, {'$set': {'handler': request.form['handler']}})
  return ''

@app.route('/clearreport', methods=['POST'])
def clearreport():
  Report.delete_one({'_id': ObjectId(request.form['_id'])})
  return ''

@app.route('/register', methods=['POST'])
def register():
  if Account.count({'_id': request.form['phone']}) > 0:
    return 'Phone number already registered.', status.HTTP_400_BAD_REQUEST
  if Accout.count({'username': request.form['username']}) > 0:
    return 'Username already in user.', status.HTTP_400_BAD_REQUEST
  account = {
    '_id': request.form['phone'],
    'username': request.form['username'],
    'password': request.form['password']
  }
  Account.insert_one(account)
  user = {
    '_id': request.form['phone'],
    'name': request.form['name'],
    'phone': request.form['phone'],
    'lat': None,
    'long': None,
    'admin': None,
    'checkedin': None,
    'token': request.form['token']
  }
  User.insert_one(user)
  keys = ['phone', 'name', 'admin', '_id']
  return jsonify({key: user[key] for key in keys})

@app.route('/login', methods=['POST'])
def login():
  account = Account.find_one({'username': request.form['username'], 'password': request.form['password']}, projection=['_id'])
  if account is None:
    return 'Account not found.', status.HTTP_401_UNAUTHORIZED
  user = User.find_one({'_id': account['_id']}, projection=['phone', 'name', 'admin', '_id'])
  return jsonify(user)

if __name__ == '__main__':
    app.run(debug=True)
