<template>
  <div class="contratos-adeudos-page">
    <div class="page-header">
      <h2>Relación de Contratos con Demás Datos Relacionados al Contrato</h2>
      <div class="breadcrumb">
        <router-link to="/">Inicio</router-link> / Contratos con Adeudos
      </div>
    </div>
    <form @submit.prevent="buscar">
      <div class="form-row">
        <label>Tipo de Aseo</label>
        <select v-model="form.parTipo">
          <option value="C">Zona Centro</option>
          <option value="H">Hospitalario</option>
          <option value="O">Ordinario</option>
        </select>
        <label>Vigencia</label>
        <select v-model="form.parVigencia">
          <option value="V">Vigente</option>
          <option value="N">Conveniado</option>
          <option value="C">Cancelado</option>
          <option value="S">Suspendido</option>
          <option value="T">Todos</option>
        </select>
        <label>Tipo Reporte</label>
        <select v-model="form.parReporte" @change="onReporteChange">
          <option value="V">Periodos Vencidos</option>
          <option value="T">Otro Periodo</option>
        </select>
        <template v-if="showPeriodo">
          <label>Periodo Corte</label>
          <input v-model="form.aso" type="number" min="2000" max="2100" style="width:80px" />
          <select v-model="form.mes" style="width:60px">
            <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
          </select>
        </template>
        <button type="submit">Buscar</button>
        <button type="button" @click="exportarExcel">Exportar Excel</button>
      </div>
    </form>
    <div v-if="loading" class="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <table v-if="contratos.length" class="data-table">
      <thead>
        <tr>
          <th>Control Contrato</th>
          <th>Contrato</th>
          <th>Calle</th>
          <th>Num. Ext.</th>
          <th>Num. Int.</th>
          <th>Colonia</th>
          <th>Sector</th>
          <th>Estatus</th>
          <th>Num. Empresa</th>
          <th>Nombre Empresa</th>
          <th>Aseo Descripción</th>
          <th>Cve. Recolec.</th>
          <th>Unidad Recolec.</th>
          <th>Cant.</th>
          <th>Inicio Oblig.</th>
          <th>Fin Oblig.</th>
          <th>$ Cond/Can/Pres</th>
          <th>$ Pagados</th>
          <th>Primer Adeudo</th>
          <th>$ Adeudos</th>
          <th>$ Recargos</th>
          <th>$ Multa</th>
          <th>$ Gastos</th>
          <th>Documentos</th>
          <th>Licencias</th>
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
          <td>{{ row.status_contrato }}</td>
          <td>{{ row.num_empresa }}</td>
          <td>{{ row.nombre_empresa }}</td>
          <td>{{ row.tipo_aseo_descripcion }}</td>
          <td>{{ row.cve_recoleccion }}</td>
          <td>{{ row.unidad_recoleccion }}</td>
          <td>{{ row.cantidad_recoleccion }}</td>
          <td>{{ row.inicio_oblig }}</td>
          <td>{{ row.fin_oblig }}</td>
          <td>{{ row.adeudos_scr | currency }}</td>
          <td>{{ row.adeudos_pag | currency }}</td>
          <td>{{ row.primer_adeudo }}</td>
          <td>{{ row.adeudos | currency }}</td>
          <td>{{ row.recargos | currency }}</td>
          <td>{{ row.req_multa | currency }}</td>
          <td>{{ row.req_gastos | currency }}</td>
          <td>{{ row.documentos }}</td>
          <td>{{ row.licencias }}</td>
        </tr>
      </tbody>
    </table>
    <div v-if="!contratos.length && !loading">No hay datos para mostrar.</div>
  </div>
</template>

<script>
export default {
  name: 'ContratosAdeudosPage',
  data() {
    const now = new Date();
    return {
      form: {
        parTipo: 'O',
        parVigencia: 'V',
        parReporte: 'V',
        aso: now.getFullYear(),
        mes: (now.getMonth() + 1).toString().padStart(2, '0')
      },
      meses: ['01','02','03','04','05','06','07','08','09','10','11','12'],
      contratos: [],
      loading: false,
      error: '',
      showPeriodo: false
    }
  },
  methods: {
    buscar() {
      this.loading = true;
      this.error = '';
      let pref = '';
      if (this.form.parReporte === 'T') {
        pref = `${this.form.aso}-${this.form.mes}`;
      } else {
        pref = `${this.form.aso}-${this.form.mes}`;
      }
      this.$axios.post('/api/execute', {
        action: 'get_contratos_adeudos',
        params: {
          parTipo: this.form.parTipo,
          parVigencia: this.form.parVigencia,
          parReporte: this.form.parReporte,
          pref: pref
        }
      }).then(res => {
        if (res.data.success) {
          this.contratos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar.';
        }
      }).catch(e => {
        this.error = e.message || 'Error de red';
      }).finally(() => {
        this.loading = false;
      });
    },
    exportarExcel() {
      // Puede ser una llamada a otro endpoint o reutilizar el mismo con un flag
      this.buscar();
      // Aquí deberías implementar la lógica para exportar a Excel
      alert('Funcionalidad de exportar a Excel no implementada en este demo.');
    },
    onReporteChange() {
      this.showPeriodo = (this.form.parReporte === 'T');
    }
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') {
        return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
      }
      return val;
    }
  },
  mounted() {
    this.buscar();
  }
}
</script>

<style scoped>
.contratos-adeudos-page {
  padding: 24px;
}
.page-header {
  margin-bottom: 16px;
}
.breadcrumb {
  font-size: 13px;
  color: #888;
  margin-bottom: 8px;
}
.form-row {
  display: flex;
  flex-wrap: wrap;
  align-items: center;
  gap: 12px;
  margin-bottom: 16px;
}
.data-table {
  width: 100%;
  border-collapse: collapse;
  margin-top: 16px;
}
.data-table th, .data-table td {
  border: 1px solid #ddd;
  padding: 4px 8px;
  font-size: 13px;
}
.data-table th {
  background: #f5f5f5;
}
.loading {
  color: #007bff;
  font-weight: bold;
}
.error {
  color: #c00;
  font-weight: bold;
}
</style>
