from flask import Flask, jsonify
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
  'token': "Uhhhhhhh..?"
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
  'token': "Uhhhhhhh..?"
}
User[blichtma['id']] = blichtma


def notify_admins(msg):
  return 5

def new_report(sender):
  id = num_reports
  report = {
    'time': strftime('%I:%M %p'),
    'id': id,
    'sender': sender
  }
  Report[id] = report
  num_reports += 1
  return id

@app.route('/checkin', methods=['POST'])
def checkin():
  id = request.form['id']
  User[id]['lat'] = request.form['lat']
  User[id]['lat'] = request.form['long']
  User[id]['checkedin'] = True

@app.route('/checkout', methods=['POST'])
def checkout():
  User[request.form['id']]['checkedin'] = False

@app.route('/report', methods=['POST'])
def report():
  id = request.form['id']
  User[id]['lat'] = request.form['lat']
  User[id]['lat'] = request.form['long']
  return jsonify({'id': new_report(id if request.form['anon'] else None)})

@app.route('/lowbatt', methods=['POST'])
def lowbatt():
  id = request.form['id']
  User[id]['lat'] = request.form['lat']
  User[id]['lat'] = request.form['long']
  notify_admins("{} has a low battery.".format(User[id]['name']))

@app.route('/reportinfo', methods=['POST'])
def reportinfo():
  id = request.form['id']
  Report[id]['data'] = request.form['data']
  notify_admins("The report opened at {} has been updated.".format(Report[id]['time']))

@app.route('/roster', methods=['GET'])
def roster():
  keys = ['name', 'phone', 'lat', 'long', 'checkedin', 'id']
  users = map(lambda user: {key: user[key] if key in user else None for key in keys}, User.values())
  return jsonify({'roster': users})

@app.route('/admins', methods=['GET'])
def admins():
  keys = ['name', 'phone', 'id']
  admin_users = filter(lambda user: user['admin'], User.values())
  admin_dicts = map(lambda user: {key: user[key] if key in user else None for key in keys}, admin_users)
  return jsonify({'admins': admin_dicts})

@app.route('/requests', methods=['GET'])
def reports():
  keys = ['id', 'sender', 'handler', 'lat', 'long', 'data']
  report_list = map(lambda report: {key: report[key] if key in report else None for key in keys}, Report.values())
  [report.update('name': "Report opened at {}".format(report['time'])) for report in report_list]
  return jsonify({'reports': report_list})

@app.route('/addadmin', methods=['POST'])
def addadmin():
  User[request.form['id']]['admin'] = True

@app.route('/deladmin', methods=['POST'])
def deladmin():
  User[request.form['id']]['admin'] = None

@app.route('/toggleduty', methods=['POST'])
def toggleduty():
  User[request.form['id']]['admin'] = not User[request.form['id']]['admin']

@app.route('/handlereport', methods=['POST'])
def handlereport():
  Report[request.form['id']]['handler'] = request.form['handler']

@app.route('/clearreport', methods=['POST'])
def clearreport():
  del Report[request.form['id']]

if __name__ == '__main__':
    app.run(debug=True)
