<template>
  <div class="rpt-calles-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Colonias para Obra</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header d-flex align-items-center">
        <img :src="logoUrl" alt="Logo" style="height:48px; margin-right:16px;">
        <div>
          <div class="h5 mb-0">MUNICIPIO DE GUADALAJARA</div>
          <div class="h6 mb-0">DIRECCION DE INGRESOS</div>
          <div class="h6">CATÁLOGO DE COLONIAS PARA OBRA: <span class="font-weight-bold">{{ axo }}</span></div>
        </div>
      </div>
      <div class="card-body">
        <form @submit.prevent="fetchData">
          <div class="form-row align-items-end">
            <div class="form-group col-md-3">
              <label for="axo">Año de Obra</label>
              <input type="number" class="form-control" id="axo" v-model.number="axo" min="1900" max="2100" required>
            </div>
            <div class="form-group col-md-2">
              <button type="submit" class="btn btn-primary">Buscar</button>
            </div>
          </div>
        </form>
        <div v-if="loading" class="text-center my-4">
          <span class="spinner-border" role="status" aria-hidden="true"></span> Cargando...
        </div>
        <div v-if="error" class="alert alert-danger">{{ error }}</div>
        <div v-if="rows.length > 0">
          <div v-for="(group, idx) in groupedRows" :key="idx" class="mb-4">
            <div class="bg-light p-2 font-weight-bold border">
              COLONIA: <span class="text-primary">{{ group.colonia_descripcion }}</span>
            </div>
            <table class="table table-sm table-bordered mb-0">
              <thead class="thead-light">
                <tr>
                  <th style="width:13%">FONDO</th>
                  <th style="width:29%">CALLE</th>
                  <th style="width:4%">FOLIO</th>
                  <th style="width:4%">CALLE #</th>
                  <th style="width:29%">OBRA PUBLICA / SERVICIO</th>
                  <th style="width:13%">ESTADO</th>
                </tr>
              </thead>
              <tbody>
                <tr v-for="row in group.items" :key="row.colonia + '-' + row.calle">
                  <td>{{ row.descripcion_2 }}</td>
                  <td>{{ row.desc_calle }}</td>
                  <td class="text-center">{{ row.colonia }}</td>
                  <td class="text-center">{{ row.calle }}</td>
                  <td>{{ row.descripcion }}</td>
                  <td>{{ row.estado }}</td>
                </tr>
              </tbody>
            </table>
          </div>
        </div>
        <div v-else-if="!loading && !error" class="alert alert-info">
          No hay datos para el año seleccionado.
        </div>
      </div>
      <div class="card-footer d-flex justify-content-between align-items-center">
        <span>RptCalles</span>
        <span>{{ now }}</span>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'RptCallesPage',
  data() {
    return {
      axo: new Date().getFullYear(),
      rows: [],
      loading: false,
      error: '',
      logoUrl: require('@/assets/logo_guadalajara.png'), // Cambia la ruta según tu proyecto
      now: new Date().toLocaleString()
    };
  },
  computed: {
    groupedRows() {
      // Agrupa por colonia (descripcion_1)
      const groups = {};
      this.rows.forEach(row => {
        const key = row.descripcion_1;
        if (!groups[key]) {
          groups[key] = {
            colonia_descripcion: row.descripcion_1,
            items: []
          };
        }
        groups[key].items.push(row);
      });
      return Object.values(groups);
    }
  },
  methods: {
    async fetchData() {
      this.loading = true;
      this.error = '';
      this.rows = [];
      try {
        const response = await fetch('/api/execute', {
          method: 'POST',
          headers: {
            'Content-Type': 'application/json',
            'Accept': 'application/json'
          },
          body: JSON.stringify({
            eRequest: {
              action: 'RptCalles.getCallesByAxo',
              data: { axo: this.axo }
            }
          })
        });
        const json = await response.json();
        if (json.eResponse && json.eResponse.status === 'success') {
          this.rows = json.eResponse.data || [];
        } else {
          this.error = json.eResponse ? json.eResponse.message : 'Error desconocido.';
        }
      } catch (err) {
        this.error = err.message || 'Error de red.';
      } finally {
        this.loading = false;
        this.now = new Date().toLocaleString();
      }
    }
  },
  mounted() {
    this.fetchData();
  }
};
</script>

<style scoped>
.rpt-calles-page .card-header {
  background: #f8f9fa;
}
.rpt-calles-page .breadcrumb {
  background: transparent;
  padding-left: 0;
}
</style>
