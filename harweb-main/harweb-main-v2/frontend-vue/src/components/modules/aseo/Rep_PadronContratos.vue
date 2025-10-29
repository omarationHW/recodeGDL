<template>
  <div class="padron-contratos-page">
    <h1>Reporte Padrón de Contratos</h1>
    <div class="filters">
      <label>Tipo de Aseo:
        <select v-model="filters.tipo">
          <option value="C">C = Zona Centro</option>
          <option value="H">H = Hospitalario</option>
          <option value="O">O = Ordinario</option>
          <option value="T">T = TODOS</option>
        </select>
      </label>
      <label>Vigencia:
        <select v-model="filters.vigencia">
          <option value="V">V = VIGENTE</option>
          <option value="N">N = CONVENIADO</option>
          <option value="C">C = CANCELADO</option>
          <option value="S">S = SUSPENDIDO</option>
          <option value="T">T = TODOS</option>
        </select>
      </label>
      <label>Periodo:
        <select v-model="filters.periodo">
          <option value="vencidos">Periodos Vencidos</option>
          <option value="otro">Otro Periodo</option>
        </select>
      </label>
      <div v-if="filters.periodo === 'otro'">
        <label>Año:
          <input type="number" v-model="filters.anio" min="2000" max="2100" />
        </label>
        <label>Mes:
          <select v-model="filters.mes">
            <option v-for="m in 12" :key="m" :value="String(m).padStart(2, '0')">{{ m }}</option>
          </select>
        </label>
      </div>
      <button @click="buscar">Buscar</button>
    </div>
    <div v-if="loading">Cargando...</div>
    <div v-if="error" class="error">{{ error }}</div>
    <div v-if="contratos.length">
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>#</th>
            <th>Tipo Aseo</th>
            <th>Contrato</th>
            <th>Empresa</th>
            <th>Domicilio</th>
            <th>Inicio Oblig.</th>
            <th>Fin Oblig.</th>
            <th>Detalle Adeudos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(c, idx) in contratos" :key="c.control_contrato">
            <td>{{ idx+1 }}</td>
            <td>{{ c.tipo_aseo_descripcion }}</td>
            <td>{{ c.num_contrato }}</td>
            <td>{{ c.nombre_empresa }}</td>
            <td>{{ c.calle }}</td>
            <td>{{ c.inicio_oblig }}</td>
            <td>{{ c.fin_oblig }}</td>
            <td>
              <button @click="verDetalle(c)">Ver</button>
            </td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="detalleAdeudos.length">
      <h2>Detalle de Adeudos - Contrato {{ detalleContrato.num_contrato }}</h2>
      <table class="table table-sm">
        <thead>
          <tr>
            <th>Concepto</th>
            <th>Adeudos</th>
            <th>Recargos</th>
            <th>Multa</th>
            <th>Gastos</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="d in detalleAdeudos" :key="d.concepto">
            <td>{{ d.concepto }}</td>
            <td>{{ d.importe_adeudos | currency }}</td>
            <td>{{ d.importe_recargos | currency }}</td>
            <td>{{ d.importe_multa | currency }}</td>
            <td>{{ d.importe_gastos | currency }}</td>
          </tr>
        </tbody>
        <tfoot>
          <tr>
            <th>Total</th>
            <th>{{ total('importe_adeudos') | currency }}</th>
            <th>{{ total('importe_recargos') | currency }}</th>
            <th>{{ total('importe_multa') | currency }}</th>
            <th>{{ total('importe_gastos') | currency }}</th>
          </tr>
        </tfoot>
      </table>
      <button @click="detalleAdeudos=[]">Cerrar Detalle</button>
    </div>
  </div>
</template>

<script>
export default {
  name: 'PadronContratosPage',
  data() {
    const now = new Date();
    return {
      filters: {
        tipo: 'T',
        vigencia: 'T',
        periodo: 'vencidos',
        anio: now.getFullYear(),
        mes: String(now.getMonth()+1).padStart(2, '0')
      },
      contratos: [],
      detalleAdeudos: [],
      detalleContrato: {},
      loading: false,
      error: ''
    }
  },
  methods: {
    async buscar() {
      this.loading = true;
      this.error = '';
      this.contratos = [];
      this.detalleAdeudos = [];
      try {
        const params = {
          tipo: this.filters.tipo,
          vigencia: this.filters.vigencia
        };
        const res = await this.$axios.post('/api/execute', {
          action: 'getPadronContratos',
          params
        });
        if (res.data.success) {
          this.contratos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    async verDetalle(contrato) {
      this.detalleContrato = contrato;
      this.detalleAdeudos = [];
      this.loading = true;
      try {
        const fecha = this.filters.periodo === 'vencidos'
          ? `${this.filters.anio}-${this.filters.mes}`
          : `${this.filters.anio}-${this.filters.mes}`;
        const res = await this.$axios.post('/api/execute', {
          action: 'getDetalleAdeudos',
          params: {
            control: contrato.control_contrato,
            rep: this.filters.periodo === 'vencidos' ? 'V' : 'A',
            fecha
          }
        });
        if (res.data.success) {
          this.detalleAdeudos = res.data.data;
        } else {
          this.error = res.data.message || 'Error al consultar detalle.';
        }
      } catch (e) {
        this.error = e.message;
      } finally {
        this.loading = false;
      }
    },
    total(field) {
      return this.detalleAdeudos.reduce((sum, d) => sum + Number(d[field] || 0), 0);
    }
  },
  filters: {
    currency(val) {
      if (typeof val !== 'number') return val;
      return val.toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  }
}
</script>

<style scoped>
.padron-contratos-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 2rem;
}
.filters {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 1rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.5rem;
}
.error {
  color: red;
  margin: 1rem 0;
}
</style>
