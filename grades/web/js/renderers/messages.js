"use strict";

// Mensajes para el usuario, con las notificaciones y las alertas de ez-ui.
import { ezToast } from "../../ez-ui/js/toast.js";

const messageRenderer = {
  // Una notificación de éxito, que se cierra sola
  showSuccessMessage: function (message) {
    ezToast(message, "success");
  },

  // Una notificación de error, que se cierra sola; si el error viene de la API, añade su motivo
  // (el campo message de la respuesta)
  showErrorMessage: function (message, error) {
    let reason = error?.response?.data?.message;
    ezToast(reason ? `${message}: ${reason}` : message, "error", 8000);
  },

  // Los errores en una alerta de error de ez-ui dentro del contenedor (sin errores, lo vacía): para
  // los que el usuario tiene que corregir, como los de un formulario, que no deben desaparecer solos
  showErrorsAsAlert: function (container, errors) {
    container.replaceChildren();
    if (errors.length === 0) {
      return;
    }
    let alert = document.createElement("div");
    alert.className = "ez-alert ez-alert--error";
    alert.setAttribute("role", "alert");
    let list = document.createElement("ul");
    for (let error of errors) {
      let item = document.createElement("li");
      item.textContent = error;
      list.append(item);
    }
    alert.append(list);
    container.append(alert);
  },
};

export { messageRenderer };
