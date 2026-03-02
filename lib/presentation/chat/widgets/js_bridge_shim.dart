class JsBridgeShim {
  static const String shim = r'''
    (function() {
      if (window.Native) return;

      const _callNative = (module, method, args) => {
        const message = {
          module: module,
          method: method,
          args: args || {},
          id: Math.random().toString(36).substr(2, 9)
        };

        return new Promise((resolve, reject) => {
          const callbackName = `native_callback_${message.id}`;
          window[callbackName] = (result, error) => {
            delete window[callbackName];
            if (error) reject(error);
            else resolve(result);
          };

          if (window.nativeBridge) {
            window.nativeBridge.postMessage(JSON.stringify(message));
          } else {
            console.error('Native bridge not available');
            reject('Native bridge not available');
          }
        });
      };

      window.Native = {
        ui: {
          showToast: (msg) => _callNative('ui', 'showToast', { message: msg }),
          showDialog: (title, msg) => _callNative('ui', 'showDialog', { title: title, message: msg }),
          confirm: (title, msg) => _callNative('ui', 'confirm', { title: title, message: msg }),
          haptic: (type) => _callNative('ui', 'haptic', { type: type })
        },
        media: {
          openCamera: () => _callNative('media', 'openCamera'),
          pickImage: () => _callNative('media', 'pickImage'),
          pickFile: (type) => _callNative('media', 'pickFile', { type: type })
        },
        clipboard: {
          copy: (text) => _callNative('clipboard', 'copy', { text: text }),
          read: () => _callNative('clipboard', 'read')
        },
        file: {
          write: (filename, content) => _callNative('file', 'write', { filename: filename, content: content }),
          read: (filename) => _callNative('file', 'read', { filename: filename }),
          delete: (filename) => _callNative('file', 'delete', { filename: filename })
        },
        intent: {
          openUrl: (url) => _callNative('intent', 'openUrl', { url: url }),
          sendEmail: (to, subject, body) => _callNative('intent', 'sendEmail', { to: to, subject: subject, body: body }),
          share: (text) => _callNative('intent', 'share', { text: text })
        }
      };

      console.log('Native Bridge Shim Injected');
    })();
  ''';
}
