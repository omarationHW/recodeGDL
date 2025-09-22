<template>
  <div class="liga-requisitos-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active">Liga de Requisitos a Giros</li>
      </ol>
    </nav>
    <h2>Liga de Requisitos a Giros</h2>
    <div class="row mb-3">
      <div class="col-md-6">
        <label for="giros-search">Buscar giro:</label>
        <input id="giros-search" v-model="girosSearch" @input="fetchGiros" class="form-control" placeholder="Buscar giro por descripción...">
      </div>
    </div>
    <div class="row mb-3">
      <div class="col-md-12">
        <table class="table table-hover table-bordered">
          <thead>
            <tr>
              <th>Id</th>
              <th>Clasificación</th>
              <th>Tipo</th>
              <th>Reglam.</th>
              <th>Descripción</th>
              <th>Acción</th>
            </tr>
          </thead>
          <tbody>
            <tr v-for="giro in giros" :key="giro.id_giro" :class="{'table-active': giro.id_giro === selectedGiroId}">
              <td>{{ giro.id_giro }}</td>
              <td>{{ giro.clasificacion }}</td>
              <td>{{ giro.tipo }}</td>
              <td>{{ giro.reglamentada }}</td>
              <td>{{ giro.descripcion }}</td>
              <td>
                <button class="btn btn-sm btn-primary" @click="selectGiro(giro)">Seleccionar</button>
              </td>
            </tr>
          </tbody>
        </table>
      </div>
    </div>
    <div v-if="selectedGiroId">
      <div class="row">
        <div class="col-md-6">
          <h4>Requisitos del Giro</h4>
          <input v-model="requisitosLigadosSearch" @input="fetchRequisitosLigados" class="form-control mb-2" placeholder="Buscar en requisitos ligados...">
          <table class="table table-sm table-bordered">
            <thead>
              <tr>
                <th>Número</th>
                <th>Requisito</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="req in requisitosLigados" :key="req.req">
                <td>{{ req.req }}</td>
                <td>{{ req.descripcion }}</td>
                <td>
                  <button class="btn btn-sm btn-danger" @click="removeRequisito(req)">Quitar</button>
                </td>
              </tr>
              <tr v-if="requisitosLigados.length === 0">
                <td colspan="3" class="text-center">Sin requisitos ligados</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="col-md-6">
          <h4>Requisitos Disponibles</h4>
          <input v-model="requisitosDisponiblesSearch" @input="fetchRequisitosDisponibles" class="form-control mb-2" placeholder="Buscar en requisitos disponibles...">
          <table class="table table-sm table-bordered">
            <thead>
              <tr>
                <th>Número</th>
                <th>Requisito</th>
                <th>Acción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="req in requisitosDisponibles" :key="req.req">
                <td>{{ req.req }}</td>
                <td>{{ req.descripcion }}</td>
                <td>
                  <button class="btn btn-sm btn-success" @click="addRequisito(req)">Agregar</button>
                </td>
              </tr>
              <tr v-if="requisitosDisponibles.length === 0">
                <td colspan="3" class="text-center">Sin requisitos disponibles</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
      <div class="row mt-4">
        <div class="col-md-12 text-end">
          <button class="btn btn-secondary me-2" @click="printReport"><i class="bi bi-printer"></i> Imprimir Listado</button>
        </div>
      </div>
    </div>
    <div v-if="alert.message" :class="['alert', alert.success ? 'alert-success' : 'alert-danger']" role="alert">
      {{ alert.message }}
    </div>
  </div>
</template>

<script>
export default {
  name: 'LigaRequisitos',
  data() {
    return {
      giros: [],
      girosSearch: '',
      selectedGiroId: null,
      selectedGiro: null,
      requisitosLigados: [],
      requisitosLigadosSearch: '',
      requisitosDisponibles: [],
      requisitosDisponiblesSearch: '',
      alert: { message: '', success: true }
    };
  },
  mounted() {
    this.fetchGiros();
  },
  methods: {
    async api(action, params = {}) {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ action, params })
      });
      return await res.json();
    },
    async fetchGiros() {
      const resp = await this.api('search_giros', { descripcion: this.girosSearch });
      if (resp.success) this.giros = resp.data;
    },
    async selectGiro(giro) {
      this.selectedGiroId = giro.id_giro;
      this.selectedGiro = giro;
      await this.fetchRequisitosLigados();
      await this.fetchRequisitosDisponibles();
    },
    async fetchRequisitosLigados() {
      if (!this.selectedGiroId) return;
      const resp = await this.api('get_requisitos_ligados', { id_giro: this.selectedGiroId });
      if (resp.success) {
        let data = resp.data;
        if (this.requisitosLigadosSearch) {
          data = data.filter(r => r.descripcion.toUpperCase().includes(this.requisitosLigadosSearch.toUpperCase()));
        }
        this.requisitosLigados = data;
      }
    },
    async fetchRequisitosDisponibles() {
      if (!this.selectedGiroId) return;
      const resp = await this.api('get_requisitos_disponibles', { id_giro: this.selectedGiroId });
      if (resp.success) {
        let data = resp.data;
        if (this.requisitosDisponiblesSearch) {
          data = data.filter(r => r.descripcion.toUpperCase().includes(this.requisitosDisponiblesSearch.toUpperCase()));
        }
        this.requisitosDisponibles = data;
      }
    },
    async addRequisito(req) {
      const resp = await this.api('add_requisito', { id_giro: this.selectedGiroId, req: req.req });
      if (resp.success) {
        this.alert = { message: 'Requisito agregado correctamente', success: true };
        await this.fetchRequisitosLigados();
        await this.fetchRequisitosDisponibles();
      } else {
        this.alert = { message: resp.message || 'Error al agregar', success: false };
      }
    },
    async removeRequisito(req) {
      const resp = await this.api('remove_requisito', { id_giro: this.selectedGiroId, req: req.req });
      if (resp.success) {
        this.alert = { message: 'Requisito eliminado correctamente', success: true };
        await this.fetchRequisitosLigados();
        await this.fetchRequisitosDisponibles();
      } else {
        this.alert = { message: resp.message || 'Error al eliminar', success: false };
      }
    },
    async printReport() {
      const resp = await this.api('print_report', { id_giro: this.selectedGiroId });
      if (resp.success && resp.url) {
        window.open(resp.url, '_blank');
      } else {
        this.alert = { message: resp.message || 'No se pudo generar el reporte', success: false };
      }
    }
  }
};
</script>

<style scoped>
.liga-requisitos-page {
  max-width: 1100px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table-active {
  background: #e6f7ff;
}
</style>
