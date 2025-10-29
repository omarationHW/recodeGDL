<template>
  <div class="cancel-account-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Cancelación de Cuenta</span>
    </div>
    <h1>Cancelación de Cuenta</h1>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-else>
      <div class="account-info">
        <h2>Datos de la Cuenta</h2>
        <div><b>Clave Catastral:</b> {{ account.cvecatnva }}</div>
        <div><b>Recaudadora:</b> {{ account.recaud }}</div>
        <div><b>Urbano/Rústico:</b> {{ account.urbrus }}</div>
        <div><b>Cuenta:</b> {{ account.cuenta }}</div>
        <div><b>Vigente:</b> <span :class="{'vigente': account.vigente==='V', 'cancelada': account.vigente!=='V'}">{{ account.vigente==='V' ? 'Vigente' : 'Cancelada' }}</span></div>
      </div>
      <div class="values-info">
        <h2>Valores</h2>
        <div><b>Valor Fiscal:</b> {{ values.valfiscal }}</div>
        <div><b>Valor Terreno:</b> {{ values.valterr }}</div>
        <div><b>Valor Construcción:</b> {{ values.valconst }}</div>
        <div><b>Superficie Terreno:</b> {{ values.areaterr }}</div>
        <div><b>Superficie Construcción:</b> {{ values.areaconst }}</div>
      </div>
      <div class="actions">
        <button v-if="!showCancelForm" @click="showCancelForm = true" :disabled="account.vigente!=='V'">Cancelar cuenta</button>
        <button v-if="showCancelForm" @click="showCancelForm = false">Cerrar</button>
      </div>
      <div v-if="showCancelForm" class="cancel-form">
        <h2>Motivo de Cancelación</h2>
        <form @submit.prevent="confirmCancel">
          <div class="form-group">
            <label for="motivo">Motivo</label>
            <input id="motivo" v-model="motivo" required />
          </div>
          <div class="form-group">
            <label for="observacion">Observación</label>
            <textarea id="observacion" v-model="observacion" rows="3"></textarea>
          </div>
          <div class="form-actions">
            <button type="submit" :disabled="submitting">Confirmar Cancelación</button>
            <button type="button" @click="showCancelForm = false">Cancelar</button>
          </div>
        </form>
        <div v-if="error" class="error">{{ error }}</div>
        <div v-if="success" class="success">Cuenta cancelada correctamente.</div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'CancelAccountPage',
  data() {
    return {
      loading: true,
      submitting: false,
      account: {},
      values: {},
      showCancelForm: false,
      motivo: '',
      observacion: '',
      error: '',
      success: false
    }
  },
  created() {
    this.loadData();
  },
  methods: {
    async loadData() {
      this.loading = true;
      const cvecuenta = this.$route.params.cvecuenta;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'show',
            params: { cvecuenta }
          }
        });
        if (res.data.eResponse.success) {
          this.account = res.data.eResponse.data.account || {};
          this.values = res.data.eResponse.data.values || {};
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      }
      this.loading = false;
    },
    async confirmCancel() {
      this.submitting = true;
      this.error = '';
      this.success = false;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'confirm_cancel',
            params: {
              cvecuenta: this.account.cvecuenta,
              motivo: this.motivo,
              observacion: this.observacion,
              usuario: this.$store.state.auth.user.username
            }
          }
        });
        if (res.data.eResponse.success) {
          this.success = true;
          this.account.vigente = 'C';
          this.showCancelForm = false;
        } else {
          this.error = res.data.eResponse.message;
        }
      } catch (e) {
        this.error = e.message;
      }
      this.submitting = false;
    }
  }
}
</script>

<style scoped>
.cancel-account-page {
  max-width: 700px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  margin-bottom: 1rem;
  font-size: 0.95em;
}
.account-info, .values-info {
  background: #f8f8f8;
  padding: 1rem;
  margin-bottom: 1rem;
  border-radius: 6px;
}
.actions {
  margin-bottom: 1rem;
}
.cancel-form {
  background: #fffbe6;
  border: 1px solid #ffe58f;
  padding: 1rem;
  border-radius: 6px;
}
.form-group {
  margin-bottom: 1rem;
}
.form-actions {
  display: flex;
  gap: 1rem;
}
.error {
  color: #b71c1c;
  margin-top: 1rem;
}
.success {
  color: #388e3c;
  margin-top: 1rem;
}
.vigente {
  color: #388e3c;
  font-weight: bold;
}
.cancelada {
  color: #b71c1c;
  font-weight: bold;
}
</style>
