from twisted.internet.protocol import Factory,Protocol
from twisted.internet import reactor

class PixelMote(Protocol):
  def connectionMade(self):
    self.factory.clients.append(self)
    print "clients are ", self.factory.clients

  def message(self, message):
          self.transport.write(message + '\n')

  def connectionLost(self, reason):
      self.factory.clients.remove(self)

  def dataReceived(self, data):
    a = data.split(':')
    if len(a) > 1:
        command = a[0]
        content = a[1]
        device = a[2]

        msg = ""
        if command == "bp":
            button_letter = 'A' if content == '0' else 'B';
            print '[Button Pressed<' + device + '>] letter = ', button_letter

        elif command == "mv":
            move_data = content.split(',');
            print '[Joystiq Moved<'+ device +'>] angle = ' + move_data[0] + ' velocity = ' + move_data[1] 
        elif command == "emv":
            print '[Joystiq Stopped Moving<'+ device +'>]'
        elif command == 'hi':
            hi_data = content.split(',');
            print '[Hello<'+ hi_data[0] + ',' + hi_data[1] +'>]'

        for c in self.factory.clients:
            c.message(msg)

factory = Factory()
factory.clients = []
factory.protocol = PixelMote 
reactor.listenTCP(25, factory)
print "PixelMote server started"
reactor.run()
