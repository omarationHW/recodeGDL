<template>
  <div class="rep-adeudcond-page">
    <nav aria-label="breadcrumb" class="mb-3">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Reporte de Adeudos Condonados</li>
      </ol>
    </nav>
    <div class="card">
      <div class="card-header">
        <h4>Reportes de Condonados (Por Contrato y Tipo)</h4>
      </div>
      <div class="card-body">
        <form @submit.prevent="onVistaPrevia">
          <div class="row mb-3">
            <div class="col-md-4">
              <label for="contrato" class="form-label">No. de Contrato</label>
              <input
                id="contrato"
                v-model="form.num_contrato"
                type="text"
                class="form-control"
                maxlength="10"
                @keypress="validateNumber($event)"
                required
              />
            </div>
            <div class="col-md-5">
              <label for="tipoAseo" class="form-label">Tipo de Aseo</label>
              <select
                id="tipoAseo"
                v-model="form.ctrol_aseo"
                class="form-select"
                required
              >
                <option v-for="tipo in tipoAseoList" :key="tipo.ctrol_aseo" :value="tipo.ctrol_aseo">
                  {{ tipo.ctrol_aseo.toString().padStart(3, '0') }} - {{ tipo.tipo_aseo }} - {{ tipo.descripcion }}
                </option>
              </select>
            </div>
            <div class="col-md-3">
              <label class="form-label">Ordenado Por</label>
              <div>
                <div class="form-check">
                  <input class="form-check-input" type="radio" id="op1" value="1" v-model="form.opcion">
                  <label class="form-check-label" for="op1">Periodo de Adeudo</label>
                </div>
                <div class="form-check">
                  <input class="form-check-input" type="radio" id="op2" value="2" v-model="form.opcion">
                  <label class="form-check-label" for="op2">Operación</label>
                </div>
              </div>
            </div>
          </div>
          <div class="d-flex justify-content-between">
            <button type="submit" class="btn btn-primary">Vista Previa</button>
            <button type="button" class="btn btn-danger" @click="onSalir">Salir</button>
          </div>
        </form>
        <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
        <div v-if="reporte.length" class="mt-4">
          <h5>Resultados del Reporte</h5>
          <table class="table table-bordered table-sm">
            <thead>
              <tr>
                <th>Periodo Pago</th>
                <th>Operación</th>
                <th>Importe</th>
                <th>Tipo Adeudo</th>
                <th>Excedencias</th>
                <th>Folio Recibo</th>
                <th>Fecha Pago</th>
                <!-- Agregar más columnas según necesidad -->
              </tr>
            </thead>
            <tbody>
              <tr v-for="row in reporte" :key="row.control_contrato + '-' + row.aso_mes_pago + '-' + row.ctrol_operacion">
                <td>{{ formatFecha(row.aso_mes_pago) }}</td>
                <td>{{ row.cve_operacion }} - {{ row.descripcion_3 }}</td>
                <td>{{ row.importe | currency }}</td>
                <td>{{ row.descripcion_3 }}</td>
                <td>{{ row.exedencias }}</td>
                <td>{{ row.folio_rcbo }}</td>
                <td>{{ formatFecha(row.fecha_hora_pago) }}</td>
              </tr>
            </tbody>
          </table>
        </div>
      </div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'RepAdeudCondPage',
  data() {
    return {
      tipoAseoList: [],
      form: {
        num_contrato: '',
        ctrol_aseo: '',
        opcion: '1'
      },
      error: '',
      reporte: []
    };
  },
  filters: {
    currency(val) {
      if (typeof val === 'number') {
        return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
      }
      return val;
    }
  },
  methods: {
    async fetchTipoAseo() {
      try {
        const res = await axios.post('/api/execute', {
          eRequest: 'get_tipo_aseo_catalog'
        });
        if (res.data.eResponse.success) {
          this.tipoAseoList = res.data.eResponse.data;
          if (this.tipoAseoList.length) {
            this.form.ctrol_aseo = this.tipoAseoList[0].ctrol_aseo;
          }
        } else {
          this.error = res.data.eResponse.message || 'Error al cargar tipos de aseo';
        }
      } catch (e) {
        this.error = 'Error de red al cargar tipos de aseo';
      }
    },
    validateNumber(evt) {
      const char = String.fromCharCode(evt.which);
      if (!/[0-9]/.test(char) && evt.which !== 8) {
        evt.preventDefault();
      }
    },
    async onVistaPrevia() {
      this.error = '';
      this.reporte = [];
      if (!this.form.num_contrato) {
        this.error = 'El No. de Contrato debe ser mayor a cero, intenta con otro.';
        return;
      }
      // Paso 1: Buscar contrato
      try {
        const contratoRes = await axios.post('/api/execute', {
          eRequest: 'get_contrato_by_numero_tipoaseo',
          params: {
            num_contrato: this.form.num_contrato,
            ctrol_aseo: this.form.ctrol_aseo
          }
        });
        if (!contratoRes.data.eResponse.success || !contratoRes.data.eResponse.data.length) {
          this.error = 'No existe el contrato o tipo de aseo seleccionado.';
          return;
        }
        const contrato = contratoRes.data.eResponse.data[0];
        // Paso 2: Buscar adeudos condonados
        const adeudosRes = await axios.post('/api/execute', {
          eRequest: 'get_adeudos_condonados_by_contrato',
          params: {
            control_contrato: contrato.control_contrato
          }
        });
        if (!adeudosRes.data.eResponse.success || !adeudosRes.data.eResponse.data.length) {
          this.error = 'No existen adeudos condonados para este contrato.';
          return;
        }
        // Paso 3: Obtener reporte
        const reporteRes = await axios.post('/api/execute', {
          eRequest: 'get_reporte_adeudos_condonados',
          params: {
            control_contrato: contrato.control_contrato,
            opcion: parseInt(this.form.opcion)
          }
        });
        if (reporteRes.data.eResponse.success) {
          this.reporte = reporteRes.data.eResponse.data;
        } else {
          this.error = reporteRes.data.eResponse.message || 'Error al generar el reporte.';
        }
      } catch (e) {
        this.error = 'Error de red o de servidor al procesar la solicitud.';
      }
    },
    onSalir() {
      this.$router.push('/');
    },
    formatFecha(fecha) {
      if (!fecha) return '';
      const d = new Date(fecha);
      return d.toLocaleDateString('es-MX');
    }
  },
  mounted() {
    this.fetchTipoAseo();
  }
};
</script>

<style scoped>
.rep-adeudcond-page {
  max-width: 900px;
  margin: 0 auto;
}
.card {
  box-shadow: 0 2px 8px rgba(0,0,0,0.08);
}
</style>
