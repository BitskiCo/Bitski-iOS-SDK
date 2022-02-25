if (window.ethereum) {
  console.warn('Already initialized a Web3 provider');
} else {
    window.ethereum = {
      callbacks: {},
      curentId: 1,
      request: (args) => {
        return new Promise((resolve, reject) => {
          window.ethereum.sendAsync(args, (result, error) => {
            if (error) {
              reject(error);
            } else {
              resolve(result);
            }
          });
        });
      },

      sendAsync: (payload, callback) => {
        if (!payload.id) {
          window.ethereum.curentId++;
          payload.id = window.ethereum.curentId;
        }
        
        payload.jsonrpc = "2.0";
        
        window.ethereum.callbacks[payload.id] = callback;
        window.webkit.messageHandlers.web3.postMessage(JSON.stringify(payload));
      },

      send: (methodOrPayload, paramsOrCallback) => {
        if (typeof (methodOrPayload) === 'string') {
          return new Promise((resolve, reject) => {
            window.ethereum.sendAsync({ method: methodOrPayload, params: paramsOrCallback }, (result, error) => {
              if (error) {
                reject(error);
              } else {
                resolve(result);
              }
            });
          });
        } else if (paramsOrCallback) {
          return window.ethereum.sendAsync(methodOrPayload, paramsOrCallback);
        } else {
          return new Promise((resolve, reject) => {
            window.ethereum.sendAsync(methodOrPayload, (result, error) => {
              if (error) {
                reject(error);
              } else {
                resolve(result);
              }
            });
          });
        }
      },
      handleCallback: (id, result, error) => {
        let callback = window.ethereum.callbacks[id];
        if (callback) {
          callback(result, error);
          delete window.ethereum.callbacks[id];
        } else {
          throw `No calback for ${id}`
        }
      }
    }
}

