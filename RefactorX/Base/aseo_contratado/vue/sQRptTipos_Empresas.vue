<template>
  <div class="container mt-4">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Catálogo de Tipos de Empresas</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header bg-primary text-white">
        <h4 class="mb-0">Catálogo de Tipos de Empresas</h4>
        <small>MUNICIPIO DE GUADALAJARA - DIRECCION DE INGRESOS</small>
      </div>
      <div class="card-body">
        <div class="mb-3">
          <label for="clasificacion" class="form-label">Clasificación por:</label>
          <select v-model="opcion" id="clasificacion" class="form-select" @change="fetchTiposEmpresas">
            <option :value="1">Número de Control</option>
            <option :value="2">Tipo</option>
            <option :value="3">Descripción</option>
          </select>
        </div>
        <div class="table-responsive">
          <table class="table table-bordered table-striped">
            <thead class="table-light">
              <tr>
                <th class="text-center">Control</th>
                <th class="text-center">Tipo</th>
                <th class="text-center">Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in tiposEmpresas" :key="row.ctrol_emp">
                <td class="text-center">{{ row.ctrol_emp }}</td>
                <td class="text-center">{{ row.tipo_empresa }}</td>
                <td>{{ row.descripcion }}</td>
              </tr>
              <tr v-if="tiposEmpresas.length === 0">
                <td colspan="3" class="text-center text-muted">No hay registros para mostrar.</td>
              </tr>
            </tbody>
          </table>
        </div>
        <div class="mt-3 text-end text-muted">
          <small>Impreso: {{ now }}</small>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'TiposEmpresasCatalogo',
  data() {
    return {
      opcion: 1,
      tiposEmpresas: [],
      now: ''
    };
  },
  methods: {
    fetchTiposEmpresas() {
      fetch('/api/execute', {
        method: 'POST',
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json'
        },
        body: JSON.stringify({
          eRequest: 'getTiposEmpresas',
          params: { opcion: this.opcion }
        })
      })
        .then(res => res.json())
        .then(json => {
          if (json.eResponse && json.eResponse.success) {
            this.tiposEmpresas = json.eResponse.data;
          } else {
            this.tiposEmpresas = [];
            alert(json.eResponse.message || 'Error al cargar los datos');
          }
        })
        .catch(() => {
          this.tiposEmpresas = [];
          alert('Error de comunicación con el servidor');
        });
    },
    updateNow() {
      const d = new Date();
      this.now = d.toLocaleString();
    }
  },
  mounted() {
    this.fetchTiposEmpresas();
    this.updateNow();
    setInterval(this.updateNow, 60000);
  }
};
</script>

<style scoped>
.card-header {
  background: #0d6efd;
  color: #fff;
}
.table th, .table td {
  vertical-align: middle;
}
</style>
