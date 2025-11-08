<template>
  <div class="contratos-page">
    <div class="breadcrumbs">
      <router-link to="/">Inicio</router-link> /
      <span>Contratos</span>
    </div>
    <h1>Relación de Contratos</h1>
    <div class="filters">
      <label>Tipo de Aseo:
        <select v-model="filters.tipo">
          <option value="C">Zona Centro</option>
          <option value="H">Hospitalario</option>
          <option value="O">Ordinario</option>
          <option value="T">Todos</option>
        </select>
      </label>
      <label>Vigencia:
        <select v-model="filters.vigencia">
          <option value="V">Vigente</option>
          <option value="N">Conveniado</option>
          <option value="C">Cancelado</option>
          <option value="S">Suspendido</option>
          <option value="T">Todos</option>
        </select>
      </label>
      <button @click="buscar">Buscar</button>
      <button @click="exportarExcel">Exportar Excel</button>
    </div>
    <div v-if="loading">Cargando...</div>
    <div v-else>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Control Contrato</th>
            <th>Contrato</th>
            <th>Calle</th>
            <th>Num. Ext.</th>
            <th>Num. Int.</th>
            <th>Colonia</th>
            <th>Sector</th>
            <th>C.P.</th>
            <th>RFC</th>
            <th>Municipio</th>
            <th>Estado</th>
            <th>CURP</th>
            <th>Estatus</th>
            <th>Num. Empresa</th>
            <th>Nombre Empresa</th>
            <th>Representante Empresa</th>
            <th>Aseo</th>
            <th>Aseo Descripción</th>
            <th>Cve. Recolec.</th>
            <th>Unidad Recolec.</th>
            <th>Cant.</th>
            <th>Inicio Oblig.</th>
            <th>Fin Oblig.</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in contratos" :key="row.control_contrato">
            <td>{{ row.control_contrato }}</td>
            <td>{{ row.num_contrato }}</td>
            <td>{{ row.calle }}</td>
            <td>{{ row.numext }}</td>
            <td>{{ row.numint }}</td>
            <td>{{ row.colonia }}</td>
            <td>{{ row.sector }}</td>
            <td>{{ row.cp }}</td>
            <td>{{ row.rfc }}</td>
            <td>{{ row.municipio }}</td>
            <td>{{ row.estado }}</td>
            <td>{{ row.curp }}</td>
            <td>{{ row.status_contrato }}</td>
            <td>{{ row.num_empresa }}</td>
            <td>{{ row.nombre_empresa }}</td>
            <td>{{ row.representante_empresa }}</td>
            <td>{{ row.tipo_aseo }}</td>
            <td>{{ row.tipo_aseo_descripcion }}</td>
            <td>{{ row.cve_recoleccion }}</td>
            <td>{{ row.unidad_recoleccion }}</td>
            <td>{{ row.cantidad_recoleccion }}</td>
            <td>{{ row.inicio_oblig }}</td>
            <td>{{ row.fin_oblig }}</td>
          </tr>
        </tbody>
      </table>
      <div v-if="contratos.length === 0">No hay resultados.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ContratosPage',
  data() {
    return {
      filters: {
        tipo: 'C',
        vigencia: 'V'
      },
      contratos: [],
      loading: false
    }
  },
  methods: {
    async buscar() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'listar',
            params: {
              tipo: this.filters.tipo,
              vigencia: this.filters.vigencia
            }
          }
        });
        this.contratos = res.data.eResponse.data || [];
      } catch (e) {
        alert('Error al buscar contratos: ' + (e.response?.data?.eResponse?.message || e.message));
      }
      this.loading = false;
    },
    async exportarExcel() {
      this.loading = true;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'excel',
            params: {
              tipo: this.filters.tipo,
              vigencia: this.filters.vigencia
            }
          }
        });
        // Aquí deberías implementar la descarga del archivo Excel
        alert('Exportación Excel generada (simulado).');
      } catch (e) {
        alert('Error al exportar: ' + (e.response?.data?.eResponse?.message || e.message));
      }
      this.loading = false;
    }
  },
  mounted() {
    this.buscar();
  }
}
</script>

<style scoped>
.contratos-page {
  padding: 2rem;
}
.filters {
  margin-bottom: 1rem;
  display: flex;
  gap: 1rem;
  align-items: center;
}
.breadcrumbs {
  margin-bottom: 1rem;
  color: #888;
}
table {
  width: 100%;
  font-size: 0.95em;
}
th, td {
  padding: 0.3em 0.5em;
  border: 1px solid #ddd;
}
</style>
