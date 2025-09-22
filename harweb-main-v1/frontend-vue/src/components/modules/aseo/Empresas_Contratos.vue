<template>
  <div class="empresas-contratos-page">
    <div class="page-header">
      <h1>Relación de Empresas y Contratos por Empresa</h1>
      <div class="breadcrumb">
        <router-link to="/">Inicio</router-link> /
        <span>Empresas y Contratos</span>
      </div>
    </div>
    <div class="filters">
      <form @submit.prevent="buscar">
        <div class="row">
          <div class="col">
            <label for="opcion">Opción</label>
            <select v-model="form.parOpc" id="opcion" class="form-control">
              <option value="A">A = Búsqueda por Filtro</option>
              <option value="T">T = Todos</option>
            </select>
          </div>
          <div class="col">
            <label for="busqueda">Dato a Buscar</label>
            <input v-model="form.parDescrip" id="busqueda" class="form-control" :disabled="form.parOpc !== 'A'" maxlength="50" />
          </div>
          <div class="col">
            <label for="tipoAseo">Tipo de Aseo</label>
            <select v-model="form.parTipo" id="tipoAseo" class="form-control">
              <option value="C">C = Zona Centro</option>
              <option value="H">H = Hospitalario</option>
              <option value="O">O = Ordinario</option>
              <option value="T">T = TODOS</option>
            </select>
          </div>
          <div class="col">
            <label for="vigencia">Vigencia</label>
            <select v-model="form.parVigencia" id="vigencia" class="form-control">
              <option value="V">V = VIGENTE</option>
              <option value="N">N = CONVENIADO</option>
              <option value="C">C = CANCELADO</option>
              <option value="S">S = SUSPENDIDO</option>
              <option value="T">T = TODOS</option>
            </select>
          </div>
          <div class="col align-self-end">
            <button type="submit" class="btn btn-primary">Buscar</button>
            <button type="button" class="btn btn-secondary ml-2" @click="limpiar">Limpiar</button>
          </div>
        </div>
      </form>
    </div>
    <div class="table-responsive mt-4">
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Num. Empresa</th>
            <th>Nombre de la Empresa</th>
            <th>Representante</th>
            <th>Tipo Emp.</th>
            <th>Tipo Descripción</th>
            <th>Control Contrato</th>
            <th>Contrato</th>
            <th>Calle</th>
            <th>Num. Ext.</th>
            <th>Num. Int.</th>
            <th>Colonia</th>
            <th>Sector</th>
            <th>C.P.</th>
            <th>R.F.C.</th>
            <th>Municipio</th>
            <th>Estado</th>
            <th>CURP</th>
            <th>Estatus</th>
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
          <tr v-if="loading">
            <td colspan="25" class="text-center">Cargando...</td>
          </tr>
          <tr v-else-if="rows.length === 0">
            <td colspan="25" class="text-center">No hay resultados</td>
          </tr>
          <tr v-for="row in rows" :key="row.control_contrato + '-' + row.num_empresa">
            <td>{{ row.num_empresa }}</td>
            <td>{{ row.nombre_empresa }}</td>
            <td>{{ row.representante_empresa }}</td>
            <td>{{ row.tipo_empresa }}</td>
            <td>{{ row.tipo_descripcion }}</td>
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
    </div>
    <div class="mt-3">
      <button class="btn btn-success" @click="exportarExcel" :disabled="rows.length === 0">Exportar a Excel</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'EmpresasContratosPage',
  data() {
    return {
      form: {
        parOpc: 'T',
        parDescrip: '',
        parTipo: 'C',
        parVigencia: 'V'
      },
      rows: [],
      loading: false
    };
  },
  methods: {
    buscar() {
      if (this.form.parOpc === 'A' && !this.form.parDescrip.trim()) {
        alert('Falta el dato de búsqueda');
        return;
      }
      this.loading = true;
      this.rows = [];
      this.$axios.post('/api/execute', {
        eRequest: 'empresas_contratos_list',
        params: { ...this.form }
      })
      .then(res => {
        if (res.data.status === 'success') {
          this.rows = res.data.data;
        } else {
          alert(res.data.message || 'Error en la consulta');
        }
      })
      .catch(err => {
        alert('Error en la consulta: ' + (err.response?.data?.message || err.message));
      })
      .finally(() => {
        this.loading = false;
      });
    },
    limpiar() {
      this.form = {
        parOpc: 'T',
        parDescrip: '',
        parTipo: 'C',
        parVigencia: 'V'
      };
      this.rows = [];
    },
    exportarExcel() {
      // Simple CSV export for demonstration
      if (!this.rows.length) return;
      const headers = [
        'Num. Empresa','Nombre de la Empresa','Representante','Tipo Emp.','Tipo Descripción','Control Contrato','Contrato','Calle','Num. Ext.','Num. Int.','Colonia','Sector','C.P.','R.F.C.','Municipio','Estado','CURP','ESTATUS','Aseo','Aseo Descripción','Cve. Recolec.','Unidad Recolec.','Cant.','Inicio Oblig.','Fin Oblig.'
      ];
      const csv = [headers.join(',')].concat(
        this.rows.map(row => headers.map(h => {
          const key = this.mapHeaderToKey(h);
          return '"' + (row[key] ?? '') + '"';
        }).join(','))
      ).join('\n');
      const blob = new Blob([csv], { type: 'text/csv' });
      const url = URL.createObjectURL(blob);
      const a = document.createElement('a');
      a.href = url;
      a.download = 'empresas_contratos.csv';
      a.click();
      URL.revokeObjectURL(url);
    },
    mapHeaderToKey(header) {
      // Map table header to API key
      const map = {
        'Num. Empresa': 'num_empresa',
        'Nombre de la Empresa': 'nombre_empresa',
        'Representante': 'representante_empresa',
        'Tipo Emp.': 'tipo_empresa',
        'Tipo Descripción': 'tipo_descripcion',
        'Control Contrato': 'control_contrato',
        'Contrato': 'num_contrato',
        'Calle': 'calle',
        'Num. Ext.': 'numext',
        'Num. Int.': 'numint',
        'Colonia': 'colonia',
        'Sector': 'sector',
        'C.P.': 'cp',
        'R.F.C.': 'rfc',
        'Municipio': 'municipio',
        'Estado': 'estado',
        'CURP': 'curp',
        'ESTATUS': 'status_contrato',
        'Aseo': 'tipo_aseo',
        'Aseo Descripción': 'tipo_aseo_descripcion',
        'Cve. Recolec.': 'cve_recoleccion',
        'Unidad Recolec.': 'unidad_recoleccion',
        'Cant.': 'cantidad_recoleccion',
        'Inicio Oblig.': 'inicio_oblig',
        'Fin Oblig.': 'fin_oblig'
      };
      return map[header] || header;
    }
  },
  mounted() {
    this.buscar();
  }
};
</script>

<style scoped>
.empresas-contratos-page {
  padding: 2rem;
}
.page-header {
  margin-bottom: 1.5rem;
}
.breadcrumb {
  font-size: 0.95rem;
  color: #888;
}
.filters {
  background: #f8f9fa;
  padding: 1rem;
  border-radius: 6px;
  margin-bottom: 1rem;
}
.table-responsive {
  max-height: 60vh;
  overflow-y: auto;
}
</style>
