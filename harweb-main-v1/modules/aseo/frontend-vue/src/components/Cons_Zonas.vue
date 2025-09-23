<template>
  <div class="cons-zonas-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Consulta de Zonas</li>
      </ol>
    </nav>
    <div class="card mb-3">
      <div class="card-header d-flex align-items-center justify-content-between">
        <div>
          <strong>Consulta de Zonas</strong>
        </div>
        <div>
          <button class="btn btn-success btn-sm mr-2" @click="exportExcel"><i class="fa fa-file-excel-o"></i> Exportar Excel</button>
          <button class="btn btn-secondary btn-sm" @click="goBack">Salir</button>
        </div>
      </div>
      <div class="card-body">
        <div class="form-group row align-items-center">
          <label class="col-sm-2 col-form-label">Clasificación por:</label>
          <div class="col-sm-10">
            <div class="btn-group btn-group-toggle" data-toggle="buttons">
              <label v-for="(item, idx) in orderOptions" :key="item.value" class="btn btn-outline-primary" :class="{'active': orderBy === item.value}">
                <input type="radio" :value="item.value" v-model="orderBy" @change="fetchData"> {{ item.label }}
              </label>
            </div>
          </div>
        </div>
        <div class="table-responsive">
          <table class="table table-bordered table-hover table-sm">
            <thead class="thead-light">
              <tr>
                <th>Control</th>
                <th>Zona</th>
                <th>Sub-Zona</th>
                <th>Descripción</th>
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in zonas" :key="row.ctrol_zona">
                <td>{{ row.ctrol_zona }}</td>
                <td>{{ row.zona }}</td>
                <td>{{ row.sub_zona }}</td>
                <td>{{ row.descripcion }}</td>
              </tr>
              <tr v-if="zonas.length === 0">
                <td colspan="4" class="text-center">No hay datos</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'ConsZonasPage',
  data() {
    return {
      zonas: [],
      orderBy: 'ctrol_zona',
      orderOptions: [
        { label: 'Control', value: 'ctrol_zona' },
        { label: 'Zona', value: 'zona' },
        { label: 'Sub-Zona', value: 'sub_zona' },
        { label: 'Descripción', value: 'descripcion' }
      ],
      loading: false,
      error: ''
    };
  },
  created() {
    this.fetchData();
  },
  methods: {
    fetchData() {
      this.loading = true;
      this.error = '';
      this.$axios.post('/api/execute', {
        eRequest: {
          operation: 'cons_zonas_list',
          params: { order: this.orderBy }
        }
      }).then(resp => {
        if (resp.data.eResponse.success) {
          this.zonas = resp.data.eResponse.data;
        } else {
          this.error = resp.data.eResponse.message || 'Error al cargar datos';
        }
      }).catch(err => {
        this.error = err.message || 'Error de red';
      }).finally(() => {
        this.loading = false;
      });
    },
    exportExcel() {
      // Exportar como Excel: frontend puede usar xlsx o similar
      // Aquí solo se descarga el JSON, el frontend debe convertirlo
      this.$axios.post('/api/execute', {
        eRequest: {
          operation: 'cons_zonas_export_excel',
          params: { order: this.orderBy }
        }
      }).then(resp => {
        if (resp.data.eResponse.success) {
          // Aquí puedes usar SheetJS/xlsx para exportar
          const rows = resp.data.eResponse.data;
          if (rows && rows.length > 0) {
            const csv = [
              ['Control', 'Zona', 'Sub-Zona', 'Descripción'],
              ...rows.map(r => [r.ctrol_zona, r.zona, r.sub_zona, r.descripcion])
            ].map(e => e.join(',')).join('\n');
            const blob = new Blob([csv], { type: 'text/csv' });
            const url = window.URL.createObjectURL(blob);
            const a = document.createElement('a');
            a.href = url;
            a.download = 'zonas.csv';
            a.click();
            window.URL.revokeObjectURL(url);
          } else {
            alert('No hay datos para exportar');
          }
        } else {
          alert(resp.data.eResponse.message || 'Error al exportar');
        }
      });
    },
    goBack() {
      this.$router.back();
    }
  }
};
</script>

<style scoped>
.cons-zonas-page {
  max-width: 900px;
  margin: 0 auto;
}
.breadcrumb {
  background: #f8f9fa;
  margin-bottom: 1rem;
}
</style>
