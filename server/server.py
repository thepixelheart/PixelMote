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
    print data

factory = Factory()
factory.clients = []
factory.protocol = PixelMote 
reactor.listenTCP(25, factory)
print "PixelMote server started"
reactor.run()
