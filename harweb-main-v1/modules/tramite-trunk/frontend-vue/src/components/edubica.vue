<template>
  <div class="edubica-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Edición de Ubicación</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">Edición de Ubicación</div>
      <div class="card-body">
        <form @submit.prevent="onSubmit">
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="cvecuenta">Cuenta Catastral</label>
              <input v-model="form.cvecuenta" type="number" class="form-control" id="cvecuenta" required />
            </div>
            <div class="col-md-4">
              <label for="calle">Calle</label>
              <select v-model="form.cvecalle" class="form-control" id="calle" required>
                <option v-for="c in calles" :key="c.cvecalle" :value="c.cvecalle">{{ c.calle }}</option>
              </select>
            </div>
            <div class="col-md-4">
              <label for="colonia">Colonia</label>
              <select v-model="form.cvecolonia" class="form-control" id="colonia" required>
                <option v-for="col in colonias" :key="col.cvecolonia" :value="col.cvecolonia">{{ col.colonia }}</option>
              </select>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="noexterior">No. Exterior</label>
              <input v-model="form.noexterior" type="text" maxlength="6" class="form-control" id="noexterior" required />
            </div>
            <div class="col-md-4">
              <label for="interior">No. Interior</label>
              <input v-model="form.interior" type="text" maxlength="5" class="form-control" id="interior" />
            </div>
            <div class="col-md-4">
              <label for="obsinter">Observaciones</label>
              <textarea v-model="form.obsinter" class="form-control" id="obsinter" rows="2"></textarea>
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-3">
              <label for="axoefec">Año de Efectos</label>
              <input v-model.number="form.axoefec" type="number" min="1900" class="form-control" id="axoefec" required />
            </div>
            <div class="col-md-3">
              <label for="bimefec">Bimestre de Efectos</label>
              <select v-model.number="form.bimefec" class="form-control" id="bimefec" required>
                <option v-for="b in [1,2,3,4,5,6]" :key="b" :value="b">{{ b }}</option>
              </select>
            </div>
            <div class="col-md-6">
              <label for="usuario">Usuario</label>
              <input v-model="form.usuario" type="text" class="form-control" id="usuario" required />
            </div>
          </div>
          <div class="row mb-3">
            <div class="col-md-12">
              <button type="submit" class="btn btn-success" :disabled="loading">Guardar Cambios</button>
              <span v-if="message" :class="{'text-success': success, 'text-danger': !success}" class="ms-3">{{ message }}</span>
            </div>
          </div>
        </form>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EdubicaPage',
  data() {
    return {
      calles: [],
      colonias: [],
      form: {
        cvecuenta: '',
        cvecalle: '',
        cvecolonia: '',
        noexterior: '',
        interior: '',
        obsinter: '',
        axoefec: '',
        bimefec: '',
        usuario: ''
      },
      loading: false,
      message: '',
      success: false
    }
  },
  created() {
    this.fetchCalles();
    this.fetchColonias();
  },
  methods: {
    async fetchCalles() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getCalles' })
      });
      const data = await res.json();
      if (data.success) this.calles = data.data;
    },
    async fetchColonias() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'getColonias' })
      });
      const data = await res.json();
      if (data.success) this.colonias = data.data;
    },
    async onSubmit() {
      this.loading = true;
      this.message = '';
      this.success = false;
      // Validación básica
      if (!this.form.cvecuenta || !this.form.cvecalle || !this.form.cvecolonia || !this.form.noexterior || !this.form.axoefec || !this.form.bimefec || !this.form.usuario) {
        this.message = 'Todos los campos obligatorios deben ser llenados.';
        this.loading = false;
        return;
      }
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action: 'saveUbicacion', params: this.form })
      });
      const data = await res.json();
      this.loading = false;
      this.message = data.message;
      this.success = data.success;
      if (data.success) {
        this.form.obsinter = '';
      }
    }
  }
}
</script>

<style scoped>
.edubica-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  margin-top: 1rem;
}
</style>
