function [buffer,boutons_lena] = ReadParPort()
global ioObj
if isempty(ioObj)
    error('Parallel port interface not open.');
end
buffer = ioObj.dll(ioObj.handle,889);
if nargout>1
    boutons_lena = [
        bitget(buffer, 8) ,... % bouton 1  C0/S7  (pin 11)
        ~bitget(buffer, 6),... % bouton 2 C2+/S5- (pin 12)
        ~bitget(buffer, 5),... % bouton 3 C3-/S4- (pin 13)
        ~bitget(buffer, 7),... % bouton 4 S6-     (pin 10)
        ~bitget(buffer, 4)];   % bouton 5 C1-/S3- (pin 15)
end
return
