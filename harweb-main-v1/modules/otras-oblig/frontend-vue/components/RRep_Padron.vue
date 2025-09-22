<template>
  <div class="rrep-padron-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Relación del Padrón de Concesiones</li>
      </ol>
    </nav>
    <h2>Relación del Padrón de Concesiones</h2>
    <div class="form-section">
      <div class="row mb-3">
        <div class="col-md-3">
          <label for="vigencia">Vigencia de la Concesión</label>
          <select v-model="vigencia" class="form-control" id="vigencia">
            <option value="T">TODOS</option>
            <option value="V">VIGENTES</option>
            <option value="C">CANCELADOS</option>
          </select>
        </div>
        <div class="col-md-3">
          <label for="adeudoTipo">Periodo de Adeudos</label>
          <select v-model="adeudoTipo" class="form-control" id="adeudoTipo" @change="onAdeudoTipoChange">
            <option value="vencidos">Periodos Vencidos</option>
            <option value="otro">Otro Periodo</option>
          </select>
        </div>
        <div class="col-md-2" v-if="adeudoTipo === 'otro'">
          <label for="anio">Año</label>
          <input v-model="anio" type="number" maxlength="4" class="form-control" id="anio" @keypress="validateYearInput" />
        </div>
        <div class="col-md-2" v-if="adeudoTipo === 'otro'">
          <label for="mes">Mes</label>
          <select v-model="mes" class="form-control" id="mes">
            <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
          </select>
        </div>
        <div class="col-md-2 d-flex align-items-end">
          <button class="btn btn-primary mr-2" @click="fetchReporte"><i class="fa fa-print"></i> Previa</button>
          <button class="btn btn-secondary" @click="goBack"><i class="fa fa-times"></i> Salir</button>
        </div>
      </div>
    </div>
    <div v-if="loading" class="text-center my-4">
      <span class="spinner-border"></span> Cargando...
    </div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="reporte.length > 0">
      <div class="report-header text-center mb-4">
        <img src="/logo_guadalajara.png" alt="Logo" style="height:60px;" />
        <h4>MUNICIPIO DE GUADALAJARA</h4>
        <h5>TESORERÍA MUNICIPAL</h5>
        <div>Dirección de Ingresos</div>
        <div><strong>Padrón de Concesiones del Rastro</strong></div>
      </div>
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th>Control</th>
            <th>Nombre del Concesionario</th>
            <th>Inicio Obl</th>
            <th>Fecha Baja</th>
            <th>Adeudos</th>
            <th>Recargos</th>
            <th>Total</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="row in reporte" :key="row.id_34_datos">
            <td>{{ row.control }}</td>
            <td>{{ row.concesionario }}</td>
            <td>{{ formatFecha(row.fecha_inicio, 'yyyy-MM') }}</td>
            <td>{{ formatFecha(row.fecha_fin, 'dd-MM-yyyy') }}</td>
            <td colspan="3" class="p-0">
              <table class="table table-sm mb-0">
                <thead>
                  <tr>
                    <th>Descripción del Adeudo</th>
                    <th>Adeudos</th>
                    <th>Recargos</th>
                  </tr>
                </thead>
                <tbody>
                  <tr v-for="adeudo in row.adeudos" :key="adeudo.expression">
                    <td>{{ adeudo.expression }}</td>
                    <td class="text-right">{{ currency(adeudo.expression_1) }}</td>
                    <td class="text-right">{{ currency(adeudo.expression_2) }}</td>
                  </tr>
                  <tr class="font-weight-bold bg-light">
                    <td class="text-right">TOTAL &rarr;</td>
                    <td class="text-right">{{ currency(sumAdeudos(row.adeudos)) }}</td>
                    <td class="text-right">{{ currency(sumRecargos(row.adeudos)) }}</td>
                  </tr>
                  <tr class="font-weight-bold bg-light">
                    <td class="text-right">TOTAL X CONTRATO</td>
                    <td colspan="2" class="text-right">{{ currency(sumAdeudos(row.adeudos) + sumRecargos(row.adeudos)) }}</td>
                  </tr>
                </tbody>
              </table>
            </td>
          </tr>
        </tbody>
      </table>
      <div class="text-right text-muted">Impreso: {{ now }}</div>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'RRepPadron',
  data() {
    const now = new Date();
    return {
      vigencia: 'T',
      adeudoTipo: 'vencidos',
      anio: now.getFullYear().toString(),
      mes: (now.getMonth() + 1).toString().padStart(2, '0'),
      meses: ['01','02','03','04','05','06','07','08','09','10','11','12'],
      reporte: [],
      loading: false,
      error: '',
      now: now.toLocaleString()
    };
  },
  methods: {
    onAdeudoTipoChange() {
      if (this.adeudoTipo === 'vencidos') {
        const now = new Date();
        this.anio = now.getFullYear().toString();
        this.mes = (now.getMonth() + 1).toString().padStart(2, '0');
      } else {
        this.anio = '';
        this.mes = '01';
      }
    },
    validateYearInput(e) {
      // Only allow numbers, max 4 digits
      if (!/[0-9]/.test(e.key) || this.anio.length >= 4) {
        e.preventDefault();
      }
    },
    goBack() {
      this.$router.back();
    },
    formatFecha(fecha, format) {
      if (!fecha) return '';
      const d = new Date(fecha);
      if (format === 'yyyy-MM') {
        return d.getFullYear() + '-' + (d.getMonth() + 1).toString().padStart(2, '0');
      } else if (format === 'dd-MM-yyyy') {
        return d.getDate().toString().padStart(2, '0') + '-' + (d.getMonth() + 1).toString().padStart(2, '0') + '-' + d.getFullYear();
      }
      return d.toLocaleDateString();
    },
    currency(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', {minimumFractionDigits:2});
    },
    sumAdeudos(adeudos) {
      return adeudos.reduce((sum, a) => sum + Number(a.expression_1 || 0), 0);
    },
    sumRecargos(adeudos) {
      return adeudos.reduce((sum, a) => sum + Number(a.expression_2 || 0), 0);
    },
    async fetchReporte() {
      this.error = '';
      if (this.adeudoTipo === 'otro' && (!this.anio || this.anio === '0')) {
        this.error = 'Falta el dato del AÑO a consultar, intentalo de nuevo';
        return;
      }
      this.loading = true;
      let rep = this.adeudoTipo === 'vencidos' ? 'V' : 'A';
      let fecha = this.anio + '-' + this.mes;
      try {
        const { data } = await axios.post('/api/execute', {
          eRequest: {
            action: 'get_concesiones_with_adeudos',
            params: {
              vigencia: this.vigencia,
              rep: rep,
              fecha: fecha
            }
          }
        });
        if (data.eResponse.success) {
          this.reporte = data.eResponse.data;
        } else {
          this.error = data.eResponse.message || 'Error al obtener datos';
        }
      } catch (err) {
        this.error = err.response?.data?.eResponse?.message || err.message;
      } finally {
        this.loading = false;
      }
    }
  },
  mounted() {
    // Carga inicial si se desea
    // this.fetchReporte();
  }
};
</script>

<style scoped>
.rrep-padron-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.form-section {
  background: #f8f9fa;
  border-radius: 6px;
  padding: 1rem 1.5rem;
  margin-bottom: 2rem;
}
.report-header img {
  margin-bottom: 10px;
}
.table-sm th, .table-sm td {
  font-size: 0.95em;
}
</style>
