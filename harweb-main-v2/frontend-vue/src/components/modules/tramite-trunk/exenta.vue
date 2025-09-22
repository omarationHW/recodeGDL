<template>
  <div class="exenta-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Registro de Exenciones</li>
      </ol>
    </nav>
    <h2>Registro de Exenciones</h2>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <form @submit.prevent="onSubmit">
      <div class="card mb-3">
        <div class="card-header">Datos del Predio</div>
        <div class="card-body">
          <div class="row mb-2">
            <div class="col-md-6">
              <label class="form-label">Propietario</label>
              <input type="text" class="form-control" :value="predio.ncompleto" readonly />
            </div>
            <div class="col-md-6">
              <label class="form-label">Ubicación</label>
              <input type="text" class="form-control" :value="predio.calle" readonly />
            </div>
          </div>
          <div class="row mb-2">
            <div class="col-md-3">
              <label class="form-label">Num. Ext.</label>
              <input type="text" class="form-control" :value="predio.noexterior" readonly />
            </div>
            <div class="col-md-3">
              <label class="form-label">Num. Int.</label>
              <input type="text" class="form-control" :value="predio.interior" readonly />
            </div>
            <div class="col-md-6">
              <label class="form-label">Observ. Ubicación</label>
              <input type="text" class="form-control" :value="predio.obsinter" readonly />
            </div>
          </div>
        </div>
      </div>
      <div class="row mb-3">
        <div class="col-md-2">
          <label class="form-label">Año de Efectos</label>
          <input type="number" class="form-control" v-model.number="form.axoefec" min="1970" required />
        </div>
        <div class="col-md-2">
          <label class="form-label">Bimestre</label>
          <select class="form-select" v-model.number="form.bimefec" required>
            <option v-for="b in [1,2,3,4,5,6]" :key="b" :value="b">{{ b }}</option>
          </select>
        </div>
        <div class="col-md-8">
          <label class="form-label">Observaciones al movimiento</label>
          <textarea class="form-control" v-model="form.observacion" rows="2"></textarea>
        </div>
      </div>
      <div class="mb-3">
        <span v-if="cuentaCancelada" class="text-danger fw-bold">Cuenta Cancelada</span>
      </div>
      <div class="mb-3">
        <button type="button" class="btn btn-primary me-2" :disabled="!canRegistrar" @click="registrarExencion">
          Registrar Exención
        </button>
        <button type="button" class="btn btn-danger me-2" :disabled="!canEliminar" @click="eliminarExencion">
          Eliminar Exención
        </button>
        <button type="button" class="btn btn-secondary" @click="$router.back()">Regresar</button>
      </div>
    </form>
    <div v-if="success" class="alert alert-success mt-3">{{ success }}</div>
  </div>
</template>

<script>
export default {
  name: 'ExentaPage',
  data() {
    return {
      cvecuenta: null,
      predio: {},
      form: {
        axoefec: new Date().getFullYear(),
        bimefec: 1,
        observacion: ''
      },
      exento: 'N',
      loading: false,
      error: '',
      success: '',
      cuentaCancelada: false
    };
  },
  computed: {
    canRegistrar() {
      return this.exento === 'N' && !this.cuentaCancelada;
    },
    canEliminar() {
      return this.exento === 'S' && !this.cuentaCancelada;
    }
  },
  created() {
    // cvecuenta puede venir por ruta o query
    this.cvecuenta = this.$route.query.cvecuenta || this.$route.params.cvecuenta;
    if (!this.cvecuenta) {
      this.error = 'No se especificó la cuenta.';
      return;
    }
    this.fetchPredio();
  },
  methods: {
    async fetchPredio() {
      this.loading = true;
      this.error = '';
      try {
        // 1. Obtener datos del predio
        let res = await this.api('getPredioData', { cvecuenta: this.cvecuenta });
        if (res.status === 'success') {
          this.predio = res.data;
        } else {
          this.error = res.message;
          this.loading = false;
          return;
        }
        // 2. Obtener status de exención
        let res2 = await this.api('getExencionStatus', { cvecuenta: this.cvecuenta });
        if (res2.status === 'success') {
          this.exento = res2.data.exento;
        }
        // 3. Consultar si la cuenta está cancelada (opcional, aquí simulado)
        // this.cuentaCancelada = ...
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async registrarExencion() {
      this.success = '';
      this.error = '';
      if (!this.form.axoefec || this.form.axoefec < 1970) {
        this.error = 'Año de efectos inválido';
        return;
      }
      if (!this.form.bimefec || this.form.bimefec < 1 || this.form.bimefec > 6) {
        this.error = 'Bimestre inválido';
        return;
      }
      this.loading = true;
      try {
        let res = await this.api('registrarExencion', {
          cvecuenta: this.cvecuenta,
          axoefec: this.form.axoefec,
          bimefec: this.form.bimefec,
          observacion: this.form.observacion
        });
        if (res.status === 'success') {
          this.success = res.message;
          this.exento = 'S';
        } else {
          this.error = res.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async eliminarExencion() {
      this.success = '';
      this.error = '';
      this.loading = true;
      try {
        let res = await this.api('eliminarExencion', {
          cvecuenta: this.cvecuenta,
          axoefec: this.form.axoefec,
          bimefec: this.form.bimefec,
          observacion: this.form.observacion
        });
        if (res.status === 'success') {
          this.success = res.message;
          this.exento = 'N';
        } else {
          this.error = res.message;
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async api(action, data) {
      // Llama al endpoint unificado
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action, data } })
      });
      const json = await res.json();
      return json.eResponse;
    }
  }
};
</script>

<style scoped>
.exenta-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
</style>
