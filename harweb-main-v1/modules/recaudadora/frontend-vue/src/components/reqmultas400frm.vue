<template>
  <div class="reqmultas400-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Requerimiento Multas 400</li>
      </ol>
    </nav>
    <h1>Consulta de Requerimientos de Multas 400</h1>
    <div class="card mb-4">
      <div class="card-body">
        <div class="form-group mb-3">
          <label>Tipo de Multa</label>
          <div>
            <label class="me-3">
              <input type="radio" value="6" v-model="tipo" /> Multas Federales
            </label>
            <label>
              <input type="radio" value="5" v-model="tipo" /> Multas Municipales
            </label>
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-md-3">
            <label>Dependencia</label>
            <input v-model="dep" type="text" class="form-control" maxlength="3" />
          </div>
          <div class="col-md-3">
            <label>Año de Acta</label>
            <input v-model.number="axo" type="number" class="form-control" />
          </div>
          <div class="col-md-3">
            <label>Número de Acta</label>
            <input v-model.number="numacta" type="number" class="form-control" />
          </div>
          <div class="col-md-3 d-flex align-items-end">
            <button class="btn btn-primary w-100" @click="buscarPorActa" :disabled="loading">Buscar por Acta</button>
          </div>
        </div>
        <div class="row mb-2">
          <div class="col-md-3">
            <label>Año req</label>
            <input v-model.number="axoReq" type="number" class="form-control" />
          </div>
          <div class="col-md-3">
            <label>Folio req</label>
            <input v-model.number="folioReq" type="number" class="form-control" />
          </div>
          <div class="col-md-3 d-flex align-items-end">
            <button class="btn btn-secondary w-100" @click="buscarPorFolio" :disabled="loading">Buscar por Folio Req</button>
          </div>
        </div>
      </div>
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="resultados.length" class="card">
      <div class="card-body">
        <h5>Resultados</h5>
        <div class="table-responsive">
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th v-for="col in columnas" :key="col">{{ col }}</th>
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
    </div>
    <div v-else-if="!loading && busquedaRealizada" class="alert alert-info">No se encontraron resultados.</div>
  </div>
</template>

<script>
export default {
  name: 'ReqMultas400Page',
  data() {
    return {
      tipo: '6', // 6: Federales, 5: Municipales
      dep: '',
      axo: '',
      numacta: '',
      axoReq: '',
      folioReq: '',
      resultados: [],
      columnas: [],
      loading: false,
      error: '',
      busquedaRealizada: false
    };
  },
  methods: {
    async buscarPorActa() {
      this.error = '';
      this.resultados = [];
      this.busquedaRealizada = false;
      if (!this.dep || !this.axo || !this.numacta) {
        this.error = 'Debe ingresar Dependencia, Año de Acta y Número de Acta.';
        return;
      }
      this.loading = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'reqmultas400_by_acta',
            params: {
              dep: this.dep,
              axo: this.axo,
              numacta: this.numacta,
              tipo: parseInt(this.tipo)
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.resultados = data.eResponse.data;
          this.columnas = this.resultados.length ? Object.keys(this.resultados[0]) : [];
        } else {
          this.error = data.eResponse.error || 'Error en la consulta.';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
        this.busquedaRealizada = true;
      }
    },
    async buscarPorFolio() {
      this.error = '';
      this.resultados = [];
      this.busquedaRealizada = false;
      if (!this.axoReq || !this.folioReq) {
        this.error = 'Debe ingresar Año req y Folio req.';
        return;
      }
      this.loading = true;
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: { 'Content-Type': 'application/json' },
          body: JSON.stringify({
            eRequest: 'reqmultas400_by_folio',
            params: {
              axo: this.axoReq,
              folio: this.folioReq,
              tipo: parseInt(this.tipo)
            }
          })
        });
        const data = await response.json();
        if (data.eResponse.success) {
          this.resultados = data.eResponse.data;
          this.columnas = this.resultados.length ? Object.keys(this.resultados[0]) : [];
        } else {
          this.error = data.eResponse.error || 'Error en la consulta.';
        }
      } catch (e) {
        this.error = 'Error de comunicación con el servidor.';
      } finally {
        this.loading = false;
        this.busquedaRealizada = true;
      }
    }
  }
};
</script>

<style scoped>
.reqmultas400-page {
  max-width: 900px;
  margin: 0 auto;
}
</style>
