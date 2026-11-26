"use strict";

// La sesión del usuario en el navegador: el token que devuelve POST /api/login y los datos del
// usuario, en sessionStorage (se borran al cerrar la pestaña). La API JS que genera Silence
// (js/api/_auto/common.js) envía ese mismo token, con la clave "token", en cada petición.
const sessionManager = {
  // Guarda la sesión: el token y el usuario de la respuesta del login
  login: function (token, user) {
    sessionStorage.setItem("token", token);
    sessionStorage.setItem("user", JSON.stringify(user));
  },

  // Borra la sesión del navegador
  logout: function () {
    sessionStorage.removeItem("token");
    sessionStorage.removeItem("user");
  },

  // El token de la sesión, o null si no hay sesión
  getToken: function () {
    return sessionStorage.getItem("token");
  },

  // Si hay una sesión iniciada
  isLogged: function () {
    return this.getToken() !== null;
  },

  // Los datos del usuario de la sesión (su fila, sin la contraseña), o null si no hay sesión
  getUser: function () {
    return JSON.parse(sessionStorage.getItem("user"));
  },
};

export { sessionManager };
