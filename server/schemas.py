import pydantic as _pydantic
    

class PublicKeyRequest_Base(_pydantic.BaseModel):
    owner_id: str
    clientPublicKeybytes: list
    hkdfNonce: list
    aesNonce: list
    
    model_config = _pydantic.ConfigDict(from_attributes=True)


class PublicKeyResponse(_pydantic.BaseModel):
    ownerId: str
    pubKey: str
    jwt: str

    model_config = _pydantic.ConfigDict(from_attributes=True)

class DataResponse(_pydantic.BaseModel):
    owner_id: str
    client_pub: str
    hkdfNonce: str
    jwt: str = None
    ciphertext: list
    mac: list
    
    model_config = _pydantic.ConfigDict(from_attributes=True)

