<template>
  <div class="multas400frm-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Multas 400</li>
      </ol>
    </nav>
    <h2>Consulta de Multas 400</h2>
    <div class="card mb-3">
      <div class="card-body">
        <div class="form-group mb-2">
          <label>Tipo de Multa:</label>
          <div>
            <label class="me-3">
              <input type="radio" value="federal" v-model="tipoMulta" /> Multas Federales
            </label>
            <label>
              <input type="radio" value="municipal" v-model="tipoMulta" /> Multas Municipales
            </label>
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-md-4">
            <label>Dependencia</label>
            <input v-model="form.dependencia" class="form-control" />
          </div>
          <div class="col-md-4">
            <label>Año de Acta</label>
            <input v-model="form.anioActa" type="number" class="form-control" />
          </div>
          <div class="col-md-4">
            <label>Número de Acta</label>
            <input v-model="form.numActa" type="number" class="form-control" />
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-md-6">
            <label>Nombre</label>
            <input v-model="form.nombre" class="form-control" />
          </div>
          <div class="col-md-6">
            <label>Ubicación</label>
            <input v-model="form.ubicacion" class="form-control" />
          </div>
        </div>
        <div class="d-flex gap-2 mt-3">
          <button class="btn btn-primary" @click="buscarPorActa">Por Acta</button>
          <button class="btn btn-secondary" @click="buscarPorNombre">Por Nombre</button>
          <button class="btn btn-info" @click="buscarPorDomicilio">Por Domicilio</button>
        </div>
      </div>
    </div>
    <div v-if="loading" class="alert alert-info">Buscando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="resultados && resultados.length">
      <h5>Resultados</h5>
      <div class="table-responsive">
        <table class="table table-bordered table-sm">
          <thead>
            <tr>
              <th v-for="(col, idx) in columnas" :key="idx">{{ col }}</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="(row, idx) in resultados" :key="idx">
              <td v-for="col in columnas" :key="col">{{ row[col] }}</td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-else-if="resultados && !resultados.length" class="alert alert-warning">
      No se encontraron resultados.
    </div>
  </div>
</template>

<script>
export default {
  name: 'Multas400Frm',
  data() {
    return {
      tipoMulta: 'federal',
      form: {
        dependencia: '',
        anioActa: '',
        numActa: '',
        nombre: '',
        ubicacion: ''
      },
      resultados: null,
      columnas: [],
      loading: false,
      error: ''
    };
  },
  methods: {
    async buscarPorActa() {
      this.error = '';
      this.resultados = null;
      this.loading = true;
      let eRequest = this.tipoMulta === 'federal' ? 'multas400_search_by_acta_fed' : 'multas400_search_by_acta_mpal';
      let params = this.tipoMulta === 'federal'
        ? {
            depfed: this.form.dependencia,
            axofed: this.form.anioActa,
            numacta: this.form.numActa
          }
        : {
            depen: this.form.dependencia,
            axoacta: this.form.anioActa,
            numacta: this.form.numActa
          };
      await this.ejecutarConsulta(eRequest, params);
    },
    async buscarPorNombre() {
      this.error = '';
      this.resultados = null;
      this.loading = true;
      let eRequest = this.tipoMulta === 'federal' ? 'multas400_search_by_nombre_fed' : 'multas400_search_by_nombre_mpal';
      let params = { nombre: this.form.nombre };
      await this.ejecutarConsulta(eRequest, params);
    },
    async buscarPorDomicilio() {
      this.error = '';
      this.resultados = null;
      this.loading = true;
      let eRequest = this.tipoMulta === 'federal' ? 'multas400_search_by_domici_fed' : 'multas400_search_by_domici_mpal';
      let params = { domici: this.form.ubicacion };
      await this.ejecutarConsulta(eRequest, params);
    },
    async ejecutarConsulta(eRequest, params) {
      try {
        const resp = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({ eRequest, params })
        });
        const data = await resp.json();
        if (data.eResponse.success) {
          this.resultados = data.eResponse.data;
          this.columnas = this.resultados && this.resultados.length ? Object.keys(this.resultados[0]) : [];
        } else {
          this.error = data.eResponse.message || 'Error en la consulta';
        }
      } catch (err) {
        this.error = err.message;
      } finally {
        this.loading = false;
      }
    }
  }
};
</script>

<style scoped>
.multas400frm-page {
  max-width: 900px;
  margin: 0 auto;
}
</style>
