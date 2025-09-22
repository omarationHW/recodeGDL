<template>
  <div class="reactiva-cuenta-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reactivación de Cuenta</li>
      </ol>
    </nav>
    <h2>Reactivación de Cuenta Catastral</h2>
    <div class="form-group">
      <label for="cvecuenta">Clave de Cuenta</label>
      <input v-model="cvecuenta" id="cvecuenta" class="form-control" type="number" @change="buscarCuenta" :disabled="loading" />
    </div>
    <div v-if="cuenta">
      <div class="card mb-3">
        <div class="card-header">Datos de la Cuenta</div>
        <div class="card-body">
          <p><strong>Vigente:</strong> <span :class="{'text-success': cuenta.cuenta.vigente==='V', 'text-danger': cuenta.cuenta.vigente==='C'}">{{ cuenta.cuenta.vigente }}</span></p>
          <p><strong>Bimestre:</strong> {{ cuenta.catastro.bimefec }}</p>
          <p><strong>Año:</strong> {{ cuenta.catastro.axoefec }}</p>
          <p><strong>Observaciones:</strong></p>
          <textarea v-model="observacion" class="form-control" rows="3" readonly></textarea>
        </div>
      </div>
      <button class="btn btn-primary" :disabled="!puedeReactivar || loading" @click="reactivarCuenta">Reactivar</button>
      <span v-if="success" class="text-success ml-3">Cuenta reactivada correctamente.</span>
      <span v-if="error" class="text-danger ml-3">{{ error }}</span>
    </div>
    <div v-else-if="cvecuenta && !loading">
      <div class="alert alert-warning">Cuenta no encontrada.</div>
    </div>
    <div v-if="loading" class="mt-3"><span class="spinner-border"></span> Procesando...</div>
  </div>
</template>

<script>
export default {
  name: 'ReactivaCuentaPage',
  data() {
    return {
      cvecuenta: '',
      cuenta: null,
      observacion: '',
      loading: false,
      error: '',
      success: false
    };
  },
  computed: {
    puedeReactivar() {
      return this.cuenta && this.cuenta.cuenta.vigente === 'C';
    }
  },
  methods: {
    async buscarCuenta() {
      this.loading = true;
      this.error = '';
      this.success = false;
      this.cuenta = null;
      this.observacion = '';
      if (!this.cvecuenta) {
        this.loading = false;
        return;
      }
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'getCuenta',
          params: { cvecuenta: this.cvecuenta }
        });
        if (res.data.success && res.data.data && res.data.data.cuenta) {
          this.cuenta = res.data.data;
          this.observacion = this.cuenta.catastro.observacion || '';
        } else {
          this.cuenta = null;
        }
      } catch (e) {
        this.error = 'Error al buscar la cuenta';
      }
      this.loading = false;
    },
    async reactivarCuenta() {
      if (!this.puedeReactivar) return;
      this.loading = true;
      this.error = '';
      this.success = false;
      try {
        const res = await this.$axios.post('/api/execute', {
          action: 'reactivarCuenta',
          params: { cvecuenta: this.cvecuenta }
        });
        if (res.data.success) {
          this.success = true;
          await this.buscarCuenta();
        } else {
          this.error = res.data.message || 'No se pudo reactivar la cuenta';
        }
      } catch (e) {
        this.error = 'Error al reactivar la cuenta';
      }
      this.loading = false;
    }
  }
};
</script>

<style scoped>
.reactiva-cuenta-page {
  max-width: 600px;
  margin: 0 auto;
}
.card {
  margin-bottom: 1rem;
}
</style>
