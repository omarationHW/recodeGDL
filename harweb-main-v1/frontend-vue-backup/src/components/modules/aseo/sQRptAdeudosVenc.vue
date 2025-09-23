<template>
  <div class="qrpt-adeudos-venc">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Estado de Cuenta de Adeudos Vencidos</li>
      </ol>
    </nav>
    <h2 class="text-center">MUNICIPIO DE GUADALAJARA</h2>
    <h4 class="text-center">DIRECCION DE INGRESOS</h4>
    <div class="mb-3">
      <label for="control_contrato">No. Contrato</label>
      <input v-model="form.control_contrato" id="control_contrato" type="number" class="form-control" />
    </div>
    <div class="mb-3">
      <label for="periodo">Periodo (yyyy-mm, opcional)</label>
      <input v-model="form.periodo" id="periodo" type="text" class="form-control" placeholder="Ej: 2024-06" />
    </div>
    <button class="btn btn-primary" @click="consultar">Consultar Estado de Cuenta</button>

    <div v-if="loading" class="my-3 text-center">
      <span class="spinner-border"></span> Cargando...
    </div>

    <div v-if="error" class="alert alert-danger my-3">{{ error }}</div>

    <div v-if="empresa" class="my-3">
      <h5>Empresa: {{ empresa.descripcion }}</h5>
      <p>Representante: {{ empresa.representante }}</p>
    </div>

    <div v-if="adeudos.length > 0" class="table-responsive">
      <table class="table table-bordered table-sm">
        <thead class="thead-light">
          <tr>
            <th>Periodo</th>
            <th>Tipo Adeudo</th>
            <th>Cantidad Excedente</th>
            <th>Importe</th>
            <th>Vig.</th>
            <th>Recargo</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in adeudos" :key="idx">
            <td>{{ row.aso_mes_pago }}</td>
            <td>{{ row.descripcion_3 }}</td>
            <td>{{ row.exedencias }}</td>
            <td class="text-right">{{ formatCurrency(row.importe) }}</td>
            <td>{{ row.status_vigencia_1 }}</td>
            <td class="text-right">{{ formatCurrency(row.recargo) }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <strong>Total Adeudos:</strong> {{ formatCurrency(totalAdeudos) }}<br />
        <strong>Total Recargos:</strong> {{ formatCurrency(totalRecargos) }}<br />
        <strong>Total a Pagar:</strong> {{ formatCurrency(totalAdeudos + totalRecargos) }}
      </div>
    </div>
    <div v-else-if="!loading && empresa">
      <div class="alert alert-info">No se encontraron adeudos vencidos para este contrato.</div>
    </div>
  </div>
</template>

<script>
export default {
  name: 'QRptAdeudosVenc',
  data() {
    return {
      form: {
        control_contrato: '',
        periodo: ''
      },
      empresa: null,
      adeudos: [],
      loading: false,
      error: '',
      totalAdeudos: 0,
      totalRecargos: 0
    };
  },
  methods: {
    async consultar() {
      this.error = '';
      this.adeudos = [];
      this.empresa = null;
      this.totalAdeudos = 0;
      this.totalRecargos = 0;
      if (!this.form.control_contrato) {
        this.error = 'Debe ingresar el número de contrato.';
        return;
      }
      this.loading = true;
      try {
        // 1. Obtener fecha actual y mes
        const hoy = new Date();
        const aso_hoy = hoy.getFullYear();
        const mes_hoy = hoy.getMonth() + 1;
        // 2. Obtener día límite para el mes actual
        let diaLimiteResp = await this.$axios.post('/api/execute', {
          action: 'getDiaLimite',
          params: { mes: mes_hoy }
        });
        let dia_limite = diaLimiteResp.data.data && diaLimiteResp.data.data[0] ? diaLimiteResp.data.data[0].dia : 0;
        // 3. Obtener datos de adeudos vencidos
        let adeudosResp = await this.$axios.post('/api/execute', {
          action: 'getAdeudosVencidos',
          params: {
            control_contrato: this.form.control_contrato,
            dia_limite: dia_limite,
            aso_hoy: aso_hoy,
            mes_hoy: mes_hoy,
            periodo: this.form.periodo || null
          }
        });
        this.adeudos = adeudosResp.data.data || [];
        // 4. Obtener empresa (si hay adeudos)
        if (this.adeudos.length > 0) {
          let emp = this.adeudos[0];
          let empresaResp = await this.$axios.post('/api/execute', {
            action: 'getEmpresa',
            params: {
              num_empresa: emp.num_empresa,
              ctrol_emp: emp.ctrol_emp
            }
          });
          this.empresa = empresaResp.data.data && empresaResp.data.data[0] ? empresaResp.data.data[0] : null;
        }
        // 5. Calcular recargos por cada adeudo
        let totalAdeudos = 0;
        let totalRecargos = 0;
        for (let row of this.adeudos) {
          let recargoResp = await this.$axios.post('/api/execute', {
            action: 'getImporteRecargo',
            params: {
              importe: row.importe,
              ctrol_operacion: row.ctrol_operacion,
              aso_mes_pago: row.aso_mes_pago,
              aso_hoy: aso_hoy,
              mes_hoy: mes_hoy
            }
          });
          row.recargo = recargoResp.data.data && recargoResp.data.data[0] ? recargoResp.data.data[0].importe_recargo : 0;
          totalAdeudos += parseFloat(row.importe);
          totalRecargos += parseFloat(row.recargo);
        }
        this.totalAdeudos = totalAdeudos;
        this.totalRecargos = totalRecargos;
      } catch (e) {
        this.error = e.response && e.response.data && e.response.data.message ? e.response.data.message : e.message;
      } finally {
        this.loading = false;
      }
    },
    formatCurrency(val) {
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
};
</script>

<style scoped>
.qrpt-adeudos-venc {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem 1rem;
}
.table th, .table td {
  font-size: 0.95rem;
}
</style>
