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

# afrieder = {
#   'name': "Alex Frieder",
#   '_id': "6312781242",
#   'username': 'afrieder',
#   'password': 'password',
#   'phone': "6312781242",
#   'lat': None,
#   'long': None,
#   'admin': None,
#   'checkedin': False,
#   'token': "Uhhhhhhh..?",
# }
# User.insert_one(afrieder)

# blichtma = {
#   'name': "Ben Lichtman",
#   '_id': "6102466685",
#   'username': 'blichtma',
#   'password': 'password',
#   'phone': "6102466685",
#   'lat': None,
#   'long': None,
#   'admin': True,
#   'checkedin': False,
#   'token': "09ec5b178f01dc1a2ae0489c1700cc4afe06682adeca6a22e267483e37e393dc",
# }
# User.insert_one(blichtma)

users = [
 ('Alex Frieder', 'afrieder', '6312781242', None),
 ('Ben Lichtman', 'blichtma', '6102466685', True),
 ('Caroline Hermans', 'chermans', '1847291844', None),
 ('Jordan Brown', 'jmbrown', '6132121099', True),
 ('Avi Romanoff', 'avi', '2019847261', False),
 ('Kenneth Cohen', 'kcohen', '8724721298', None),
 ('Isaac Haberman', 'ihaberma', '9347162626', False),
 ('Klaus Sutner', 'ksutner', '1241240999', None),
 ('Manuel Blum', 'mblum', '8472359893', None)
]

for (name, username, phone, admin) in users:
  user = {
    'name': name,
    '_id': phone,
    'username': username,
    'password': 'password',
    'phone': phone,
    'lat': None,
    'long': None,
    'admin': admin,
    'checkedin': False,
    'token': "09ec5b178f01dc1a2ae0489c1700cc4afe06682adeca6a22e267483e37e393dc"
  }
  User.insert_one(user)

def notify_users(users, msg):
  for user in users:
    payload = Payload(alert=msg, sound="default", badge=1)
    apns.gateway_server.send_notification(user['token'], payload)

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
  lat = request.form['lat']
  longg = request.form['long']
  User.update_one({'_id':user_id}, {'$set': {'lat': lat, 'long': longg}})
  report = {
    'time': strftime('%I:%M %p'),
    'sender': None,
    '_sender': user_id,
    'lat': lat,
    'long': longg,
    'handler': None,
    'needs_help': None,
    'location': None,
    'drunk': False,
    'drugs': False,
    'sa': False,
    'other': False
  }
  report_id = Report.insert_one(report).inserted_id
  msg = "A new report has been opened!"
  admins = User.find(filter={'admin':True}, projection={"token":True})
  notify_users(admins, msg)
  return jsonify({'_id': str(report_id)})

@app.route('/lowbatt', methods=['POST'])
def lowbatt():
  user_id = request.form['_id']
  lat = request.form['lat']
  longg = request.form['long']
  User.update_one({'_id':user_id}, {'$set': {'lat': lat, 'long': longg}})
  name = User.find_one({'_id':user_id}, projection={'name':True})['name']
  admins = User.find(filter={'admin':True}, projection={"token":True})
  notify_users(admins, "{} has a low battery.".format(name))
  return ''

@app.route('/reportinfo', methods=['POST'])
def reportinfo():
  report_id = ObjectId(request.form['_id'])
  needs_help = request.form['needs_help']
  location = request.form['location']
  drunk = request.form['drunk'] in ('true', 'True')
  sa = request.form['sa'] in ('true', 'True')
  drugs = request.form['drugs'] in ('true', 'True')
  other = request.form['other'] in ('true', 'True')
  _sender = request.form['sender']
  anon = request.form['anon'] in ('true', 'True')
  Report.update_one({'_id':report_id}, {'$set':
    {'location': location, 'needs_help': needs_help, 'sender': None if anon else _sender,
     'drunk': drunk, 'drugs': drugs, 'sa': sa, 'other': other}})
  time = Report.find_one({'_id': report_id}, projection={'time':True})['time']
  admins = User.find(filter={'admin':True}, projection={"token":True})
  notify_users(admins, "The report opened at {} has been updated.".format(time))
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
  keys = ['name', 'phone', '_id', 'admin']
  users = User.find(filter={'$or': [{'admin': True}, {'admin': False}]}, projection=keys)
  return jsonify({'admins': list(users)})

@app.route('/reports', methods=['GET'])
def reports():
  keys = ['_id', 'sender', 'handler', 'lat', 'long', 'drunk', 'sa', 'drugs', 'other', 'location', 'needs_help', 'time']
  report_list = list(Report.find(projection=keys))
  [report.update(_id=str(report['_id']),name='Report opened at {}'.format(report['time'])) for report in report_list]
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
  report = Report.find_one_and_update({'_id': ObjectId(request.form['_id'])}, {'$set': {'handler': request.form['handler']}})
  name = User.find_one({'_id': request.form['handler']}, projection={'name':True})['name']
  user = User.find_one({'_id': report['_sender']}, projection={'token': True})
  notify_users([user], "{} is handling your report.".format(name))
  return ''

@app.route('/clearreport', methods=['POST'])
def clearreport():
  Report.delete_one({'_id': ObjectId(request.form['_id'])})
  return ''

@app.route('/register', methods=['POST'])
def register():
  if User.count({'_id': request.form['phone']}) > 0:
    return 'Phone number already registered.', status.HTTP_400_BAD_REQUEST
  if User.count({'username': request.form['username']}) > 0:
    return 'Username already in user.', status.HTTP_400_BAD_REQUEST
  user = {
    '_id': request.form['phone'],
    'username': request.form['username'],
    'password': request.form['password'],
    'name': request.form['name'],
    'phone': request.form['phone'],
    'lat': None,
    'long': None,
    'admin': None,
    'checkedin': False,
    'token': request.form['token']
  }
  User.insert_one(user)
  keys = ['phone', 'name', 'admin', '_id']
  return jsonify({key: user[key] for key in keys})

@app.route('/login', methods=['POST'])
def login():
  user = User.find_one({'username': request.form['username'], 'password': request.form['password']}, projection=['phone', 'name', 'admin', '_id'])
  if user is None:
    return 'User not found.', status.HTTP_401_UNAUTHORIZED
  return jsonify(user)

@app.route('/curadmin', methods=['POST'])
def curadmin():
  return jsonify(User.find_one({'_id':request.form['_id']}, projection={'admin':True}))

if __name__ == '__main__':
    app.run(debug=True)
