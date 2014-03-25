function data = ReadParPort()

	global ioObj;
    
    buffer = io32(ioObj,889);
    
    data = 0;
    if bitand(buffer, 128) % bouton 1 C0/S7 pin 11
        data = bitor(data, 1);
    end
    if ~bitand(buffer, 32) % bouton 2 C2+/S5- pin 12
        data = bitor(data, 2);
    end
    if ~bitand(buffer, 16) % bouton 3 C3-/S4- (pin 13)
        data = bitor(data, 4);
    end
    if ~bitand(buffer, 64) % bouton 4 S6- (pin 10)
        data = bitor(data, 8);
    end
    if ~bitand(buffer, 8) % bouton 5 C1-/S3- (pin 15)
        data = bitor(data, 16);
    end
    
end
