<template>
  <div class="impno-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Impresión de Notificaciones</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        Impresión de Notificaciones
      </div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-2">
              <label for="recaud" class="form-label"><strong>Recaud.</strong></label>
              <input type="text" v-model="form.recaud" id="recaud" class="form-control" maxlength="10" required autofocus />
            </div>
            <div class="col-md-3">
              <label for="urbrus" class="form-label"><strong>Tipo de predio</strong></label>
              <select v-model="form.urbrus" id="urbrus" class="form-select" required>
                <option value="U">Urbano</option>
                <option value="R">Rústico</option>
              </select>
            </div>
            <div class="col-md-2">
              <label for="cuenta" class="form-label"><strong>Cuenta</strong></label>
              <input type="text" v-model="form.cuenta" id="cuenta" class="form-control" maxlength="10" required />
            </div>
            <div class="col-md-2 align-self-end">
              <button type="submit" class="btn btn-success w-100">Buscar</button>
            </div>
          </div>
        </form>
        <div v-if="loading" class="alert alert-info">Buscando información...</div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="notificationData" class="mt-4">
          <h5>Datos de Notificación</h5>
          <pre class="bg-light p-3">{{ notificationData | pretty }}</pre>
          <button class="btn btn-primary mt-2" @click="printNotification">Imprimir Notificación</button>
        </div>
        <div v-if="printMessage" class="alert alert-success mt-3">{{ printMessage }}</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ImpnoNotificationPage',
  data() {
    return {
      form: {
        recaud: '',
        urbrus: 'U',
        cuenta: ''
      },
      loading: false,
      error: '',
      notificationData: null,
      printMessage: ''
    };
  },
  filters: {
    pretty(value) {
      return JSON.stringify(value, null, 2);
    }
  },
  methods: {
    async onSubmit() {
      this.error = '';
      this.notificationData = null;
      this.printMessage = '';
      if (!this.form.recaud || !this.form.urbrus || !this.form.cuenta) {
        this.error = 'No se han asignado los datos completos ...';
        return;
      }
      if (this.form.urbrus !== 'U' && this.form.urbrus !== 'R') {
        this.error = 'Error en el tipo de predio, verificar ...';
        return;
      }
      this.loading = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'impno_get_notification_data',
            params: {
              recaud: this.form.recaud,
              urbrus: this.form.urbrus,
              cuenta: this.form.cuenta
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.notificationData = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'No se encontró el registro ...';
        }
      } catch (err) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
      }
    },
    async printNotification() {
      if (!this.notificationData) return;
      this.printMessage = '';
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: 'impno_print_notification',
            params: {
              notificationData: this.notificationData
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.printMessage = data.eResponse.message;
        } else {
          this.printMessage = 'No se pudo imprimir la notificación.';
        }
      } catch (err) {
        this.printMessage = 'Error de comunicación con el servidor.';
      }
    }
  }
};
</script>

<style scoped>
.impno-page {
  max-width: 800px;
  margin: 0 auto;
}
pre {
  font-size: 0.95em;
}
</style>
