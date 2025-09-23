<template>
  <div class="bloqctasreq-page">
    <h1>Bloquear/Desbloquear Cuentas para Requerir</h1>
    <form @submit.prevent="buscarCuenta">
      <div class="form-row">
        <label>Recaudadora</label>
        <input v-model="form.recaud" type="number" required />
        <label>Urb/Rus</label>
        <input v-model="form.urbrus" maxlength="1" required />
        <label>Cuenta</label>
        <input v-model="form.cuenta" type="number" required />
        <button type="submit">Buscar</button>
      </div>
    </form>
    <div v-if="cuenta">
      <h2>Datos de la Cuenta</h2>
      <div><strong>Contribuyente:</strong> {{ cuenta.ncompleto }}</div>
      <div><strong>Calle:</strong> {{ cuenta.calle }} {{ cuenta.noexterior }} Int. {{ cuenta.interior }}</div>
      <div><strong>Ubicación:</strong> {{ cuenta.calle_1 }} {{ cuenta.noexterior_1 }} Int. {{ cuenta.interio_1 }}</div>
      <div><strong>Estado:</strong> <span :class="{'bloqueada': bloqueo, 'desbloqueada': !bloqueo}">{{ bloqueo ? 'Bloqueada' : 'Desbloqueada' }}</span></div>
      <div v-if="bloqueo">
        <h3>Desbloquear Cuenta</h3>
        <form @submit.prevent="desbloquearCuenta">
          <label>Motivo desbloqueo</label>
          <textarea v-model="form.motivo" required></textarea>
          <label>Fecha desbloqueo</label>
          <input v-model="form.fecha_desbloqueo" type="date" required />
          <button type="submit">Desbloquear</button>
        </form>
      </div>
      <div v-else>
        <h3>Bloquear Cuenta</h3>
        <form @submit.prevent="bloquearCuenta">
          <label>Motivo bloqueo</label>
          <textarea v-model="form.motivo" required></textarea>
          <label>Fecha desbloqueo</label>
          <input v-model="form.fecha_desbloqueo" type="date" required />
          <button type="submit">Bloquear</button>
        </form>
      </div>
      <div>
        <h3>Historial de Bloqueos</h3>
        <table>
          <thead>
            <tr>
              <th>Fecha Bloqueo</th>
              <th>Motivo</th>
              <th>Usuario</th>
              <th>Fecha Desbloqueo</th>
              <th>Usuario Desbloqueo</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="h in historial" :key="h.id">
              <td>{{ h.feccap }}</td>
              <td>{{ h.observacion }}</td>
              <td>{{ h.capturista }}</td>
              <td>{{ h.fecbaja }}</td>
              <td>{{ h.user_baja }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="success" class="success">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'BloqCtasReqPage',
  data() {
    return {
      form: {
        recaud: '',
        urbrus: '',
        cuenta: '',
        motivo: '',
        fecha_desbloqueo: '',
        usuario: '' // set from auth
      },
      cuenta: null,
      bloqueo: false,
      historial: [],
      error: '',
      success: ''
    }
  },
  methods: {
    async buscarCuenta() {
      this.error = '';
      this.success = '';
      this.cuenta = null;
      this.historial = [];
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.consultar',
          payload: {
            recaud: this.form.recaud,
            urbrus: this.form.urbrus,
            cuenta: this.form.cuenta
          }
        });
        if (res.data.status === 'success') {
          this.cuenta = res.data.data.cuenta;
          this.bloqueo = !!res.data.data.bloqueo && !res.data.data.bloqueo.user_baja;
          this.historial = res.data.data.historial;
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    },
    async bloquearCuenta() {
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.bloquear',
          payload: {
            recaud: this.form.recaud,
            urbrus: this.form.urbrus,
            cuenta: this.form.cuenta,
            motivo: this.form.motivo,
            fecha_desbloqueo: this.form.fecha_desbloqueo,
            usuario: this.form.usuario
          }
        });
        if (res.data.status === 'success') {
          this.success = 'Cuenta bloqueada correctamente';
          this.buscarCuenta();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    },
    async desbloquearCuenta() {
      this.error = '';
      this.success = '';
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'recaudadora.desbloquear',
          payload: {
            recaud: this.form.recaud,
            urbrus: this.form.urbrus,
            cuenta: this.form.cuenta,
            motivo: this.form.motivo,
            fecha_desbloqueo: this.form.fecha_desbloqueo,
            usuario: this.form.usuario
          }
        });
        if (res.data.status === 'success') {
          this.success = 'Cuenta desbloqueada correctamente';
          this.buscarCuenta();
        } else {
          this.error = res.data.message;
        }
      } catch (e) {
        this.error = 'Error de conexión: ' + e.message;
      }
    }
  },
  mounted() {
    // Aquí deberías obtener el usuario autenticado
    this.form.usuario = 'usuario_demo';
  }
}
</script>

<style scoped>
.bloqctasreq-page { max-width: 800px; margin: 0 auto; }
.form-row { display: flex; gap: 1em; align-items: center; margin-bottom: 1em; }
.error { color: red; margin-top: 1em; }
.success { color: green; margin-top: 1em; }
.bloqueada { color: red; font-weight: bold; }
.desbloqueada { color: green; font-weight: bold; }
table { width: 100%; border-collapse: collapse; margin-top: 1em; }
th, td { border: 1px solid #ccc; padding: 0.5em; }
</style>
