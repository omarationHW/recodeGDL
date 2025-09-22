<template>
  <div class="adeudos-venc-page">
    <h1>Consulta de Adeudos Vencidos</h1>
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Adeudos Vencidos</li>
      </ol>
    </nav>
    <form @submit.prevent="buscarContrato">
      <div class="form-row">
        <div class="form-group col-md-3">
          <label for="contrato">Contrato</label>
          <input v-model="form.contrato" id="contrato" type="text" class="form-control" maxlength="10" required />
        </div>
        <div class="form-group col-md-4">
          <label for="tipoAseo">Tipo de Aseo</label>
          <select v-model="form.ctrol_aseo" id="tipoAseo" class="form-control" required>
            <option v-for="ta in tipoAseoList" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
              {{ ta.ctrol_aseo.toString().padStart(3, '0') }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
            </option>
          </select>
        </div>
        <div class="form-group col-md-3">
          <label for="vigencia">Vigencia</label>
          <select v-model="form.vigencia" id="vigencia" class="form-control">
            <option value="V">Periodos Vigentes</option>
            <option value="O">Otro Periodo</option>
          </select>
        </div>
      </div>
      <div v-if="form.vigencia === 'O'" class="form-row">
        <div class="form-group col-md-2">
          <label for="aso">Año</label>
          <input v-model="form.aso" id="aso" type="number" class="form-control" min="2000" max="2100" />
        </div>
        <div class="form-group col-md-2">
          <label for="mes">Mes</label>
          <select v-model="form.mes" id="mes" class="form-control">
            <option v-for="m in meses" :key="m.value" :value="m.value">{{ m.text }}</option>
          </select>
        </div>
      </div>
      <button type="submit" class="btn btn-primary mt-2">Buscar</button>
    </form>

    <div v-if="contratoData" class="mt-4">
      <h3>Datos del Contrato</h3>
      <table class="table table-bordered">
        <tr><th>Empresa</th><td>{{ contratoData.nom_emp }}</td></tr>
        <tr><th>Representante</th><td>{{ contratoData.representante }}</td></tr>
        <tr><th>Tipo de Aseo</th><td>{{ contratoData.desc_aseo }}</td></tr>
        <tr><th>Domicilio</th><td>{{ contratoData.domicilio }}</td></tr>
        <tr><th>Zona</th><td>{{ contratoData.nom_zona }}</td></tr>
        <tr><th>Vigencia</th><td>{{ contratoData.status_vigencia }}</td></tr>
        <tr><th>Inicio Obligación</th><td>{{ contratoData.aso_mes_oblig | fecha }}</td></tr>
      </table>
      <button class="btn btn-success mb-3" @click="consultarAdeudos">Consultar Adeudos</button>
    </div>

    <div v-if="adeudos.length" class="mt-4">
      <h3>Adeudos Vencidos</h3>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Periodo</th>
            <th>Operación</th>
            <th>Descripción</th>
            <th>Exedencias</th>
            <th>Importe</th>
            <th>Recargos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="ad in adeudos" :key="ad.aso_mes_pago + '-' + ad.ctrol_operacion">
            <td>{{ ad.aso_mes_pago | fechaPeriodo }}</td>
            <td>{{ ad.ctrol_operacion }}</td>
            <td>{{ ad.descripcion }}</td>
            <td>{{ ad.exedencias }}</td>
            <td>{{ ad.importe | moneda }}</td>
            <td>{{ ad.recargos | moneda }}</td>
          </tr>
        </tbody>
      </table>
      <div class="mt-3">
        <button class="btn btn-info" @click="verReporte">Ver Reporte</button>
      </div>
    </div>

    <div v-if="reporte" class="mt-4">
      <h3>Resumen de Adeudos</h3>
      <table class="table table-bordered">
        <tr><th>Requerimientos</th><td>{{ reporte.requerimientos }}</td></tr>
        <tr><th>Importe Multa</th><td>{{ reporte.importe_multa | moneda }}</td></tr>
        <tr><th>Importe Gastos</th><td>{{ reporte.importe_gastos | moneda }}</td></tr>
        <tr><th>Importe Recargos</th><td>{{ reporte.importe_recargos | moneda }}</td></tr>
        <tr><th>Total Adeudos</th><td>{{ reporte.total_adeudos | moneda }}</td></tr>
      </table>
    </div>

    <div v-if="error" class="alert alert-danger mt-3">{{ error }}</div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosVencPage',
  data() {
    return {
      tipoAseoList: [],
      meses: [
        { value: 1, text: 'Enero' }, { value: 2, text: 'Febrero' }, { value: 3, text: 'Marzo' },
        { value: 4, text: 'Abril' }, { value: 5, text: 'Mayo' }, { value: 6, text: 'Junio' },
        { value: 7, text: 'Julio' }, { value: 8, text: 'Agosto' }, { value: 9, text: 'Septiembre' },
        { value: 10, text: 'Octubre' }, { value: 11, text: 'Noviembre' }, { value: 12, text: 'Diciembre' }
      ],
      form: {
        contrato: '',
        ctrol_aseo: '',
        vigencia: 'V',
        aso: '',
        mes: 1
      },
      contratoData: null,
      adeudos: [],
      reporte: null,
      error: null
    }
  },
  filters: {
    fecha(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    fechaPeriodo(val) {
      if (!val) return '';
      const d = new Date(val);
      return d.toLocaleString('default', { month: 'long', year: 'numeric' });
    },
    moneda(val) {
      if (val == null) return '';
      return '$' + Number(val).toLocaleString('es-MX', { minimumFractionDigits: 2 });
    }
  },
  created() {
    this.loadTipoAseo();
  },
  methods: {
    async loadTipoAseo() {
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: { action: 'getTipoAseo' }
        });
        this.tipoAseoList = res.data.eResponse;
        if (this.tipoAseoList.length) this.form.ctrol_aseo = this.tipoAseoList[0].ctrol_aseo;
      } catch (e) {
        this.error = 'Error cargando tipos de aseo';
      }
    },
    async buscarContrato() {
      this.error = null;
      this.contratoData = null;
      this.adeudos = [];
      this.reporte = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'buscarContrato',
            params: {
              num_contrato: this.form.contrato,
              ctrol_aseo: this.form.ctrol_aseo
            }
          }
        });
        if (res.data.eResponse && res.data.eResponse.length) {
          this.contratoData = res.data.eResponse[0];
        } else {
          this.error = 'No se encontró el contrato.';
        }
      } catch (e) {
        this.error = 'Error buscando contrato.';
      }
    },
    async consultarAdeudos() {
      this.error = null;
      this.adeudos = [];
      this.reporte = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getAdeudos',
            params: {
              control_contrato: this.contratoData.control_contrato,
              vigencia: this.form.vigencia,
              aso: this.form.aso,
              mes: this.form.mes
            }
          }
        });
        this.adeudos = res.data.eResponse || [];
      } catch (e) {
        this.error = 'Error consultando adeudos.';
      }
    },
    async verReporte() {
      this.error = null;
      try {
        const res = await this.$axios.post('/api/execute', {
          eRequest: {
            action: 'getReporte',
            params: {
              control_contrato: this.contratoData.control_contrato,
              vigencia: this.form.vigencia,
              aso: this.form.aso,
              mes: this.form.mes
            }
          }
        });
        this.reporte = res.data.eResponse && res.data.eResponse[0] ? res.data.eResponse[0] : null;
      } catch (e) {
        this.error = 'Error generando reporte.';
      }
    }
  }
}
</script>

<style scoped>
.adeudos-venc-page {
  max-width: 900px;
  margin: 0 auto;
  padding: 2rem;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
