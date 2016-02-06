from flask import Flask, jsonify, request
from flask.ext.api import status
from apns import APNs, Payload
from time import strftime

app = Flask(__name__)
apns = APNs(use_sandbox=True, cert_file="cert_file.pem", key_file="key_file.pem")

User = {}
Report = {}
num_reports = 0

afrieder = {
  'name': "Alex Frieder",
  'id': "6312781242",
  'phone': "6312781242",
  'lat': None,
  'long': None,
  'admin': None,
  'checkedin': False,
  'token': "Uhhhhhhh..?",
}
User[afrieder['id']] = afrieder

blichtma = {
  'name': "Ben Lichtman",
  'id': "6102466685",
  'phone': "6102466685",
  'lat': None,
  'long': None,
  'admin': True,
  'checkedin': False,
  'token': "Uhhhhhhh..?",
}
User[blichtma['id']] = blichtma

def get_admins():
  return filter(lambda user: user['admin'], User.values())

def notify_admins(msg):
  admins = get_admins()
  for admin in admins:
    payload = Payload(alert=msg, sound="default", badge=1)
    apns.gateway_server.send_notification(admin['token'], payload)

def new_report(sender):
  global num_reports
  report_id = num_reports
  report = {
    'time': strftime('%I:%M %p'),
    'id': report_id,
    'sender': sender
  }
  Report[report_id] = report
  num_reports += 1
  return report_id

@app.route('/checkin', methods=['POST'])
def checkin():
  user_id = request.form['id']
  User[user_id]['lat'] = request.form['lat']
  User[user_id]['long'] = request.form['long']
  User[user_id]['checkedin'] = True
  return ''

@app.route('/checkout', methods=['POST'])
def checkout():
  user_id = request.form['id']
  User[user_id]['checkedin'] = False
  User[user_id]['lat'] = None
  User[user_id]['long'] = None
  return ''

@app.route('/report', methods=['POST'])
def report():
  user_id = request.form['id']
  User[user_id]['lat'] = request.form['lat']
  User[user_id]['long'] = request.form['long']
  return jsonify({'id': new_report(user_id if not request.form['anon'] else None)})

@app.route('/lowbatt', methods=['POST'])
def lowbatt():
  user_id = request.form['id']
  User[user_id]['lat'] = request.form['lat']
  User[user_id]['long'] = request.form['long']
  notify_admins("{} has a low battery.".format(User[user_id]['name']))
  return ''

@app.route('/reportinfo', methods=['POST'])
def reportinfo():
  user_id = request.form['id']
  Report[user_id]['data'] = request.form['data']
  notify_admins("The report opened at {} has been updated.".format(Report[user_id]['time']))
  return ''

@app.route('/roster', methods=['GET'])
def roster():
  keys = ['name', 'phone', 'lat', 'long', 'checkedin', 'id']
  users = map(lambda user: {key: user[key] if key in user else None for key in keys}, User.values())
  return jsonify({'roster': users})

@app.route('/checkedin', methods=['GET'])
def checkedin():
  keys = ['name', 'phone', 'lat', 'long', 'id']
  users = filter(lambda user: user['checkedin'], User.values())
  users = map(lambda user: {key: user[key] if key in user else None for key in keys}, users)
  return jsonify({'roster': users})

@app.route('/admins', methods=['GET'])
def admins():
  keys = ['name', 'phone', 'id']
  admin = map(lambda user: {key: user[key] if key in user else None for key in keys}, get_admins())
  return jsonify({'admins': admin})

@app.route('/reports', methods=['GET'])
def reports():
  keys = ['id', 'sender', 'handler', 'lat', 'long', 'data', 'time']
  report_list = map(lambda report: {key: report[key] if key in report else None for key in keys}, Report.values())
  [report.update(name="Report opened at {}".format(report['time'])) for report in report_list]
  return jsonify({'reports': report_list})

@app.route('/addadmin', methods=['POST'])
def addadmin():
  User[request.form['id']]['admin'] = True
  return ''

@app.route('/deladmin', methods=['POST'])
def deladmin():
  if len(get_admins()) == 1:
    return 'You are the only admin. You cannot delete yourself.', status.HTTP_406_NOT_ACCEPTABLE
  User[request.form['id']]['admin'] = None
  return ''

@app.route('/toggleduty', methods=['POST'])
def toggleduty():
  if len(get_admins()) == 1:
    return 'You are the only admin. You cannot go off-duty.', status.HTTP_406_NOT_ACCEPTABLE
  User[request.form['id']]['admin'] = not User[request.form['id']]['admin']
  return ''

@app.route('/handlereport', methods=['POST'])
def handlereport():
  Report[request.form['id']]['handler'] = request.form['handler']
  return ''

@app.route('/clearreport', methods=['POST'])
def clearreport():
  del Report[request.form['id']]
  return ''

if __name__ == '__main__':
    app.run(debug=True)
