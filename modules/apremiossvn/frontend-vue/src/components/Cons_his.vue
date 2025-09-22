<template>
  <div class="cons-his-page">
    <nav aria-label="breadcrumb">
      <ol class="breadcrumb">
        <li class="breadcrumb-item"><router-link to="/">Inicio</router-link></li>
        <li class="breadcrumb-item active" aria-current="page">Modificar Folio de Apremios</li>
      </ol>
    </nav>
    <h2>Modificar Folio de Apremios</h2>
    <div v-if="loading" class="alert alert-info">Cargando...</div>
    <div v-if="error" class="alert alert-danger">{{ error }}</div>
    <div v-if="historia">
      <div class="row mb-3">
        <div class="col-md-2"><strong>Aplicación:</strong> {{ historia.modulo }}</div>
        <div class="col-md-2"><strong>Folio:</strong> {{ historia.folio }}</div>
        <div class="col-md-2"><strong>Rec de Folio:</strong> {{ historia.zona }}</div>
        <div class="col-md-2"><strong>Control de Folio:</strong> {{ historia.control }}</div>
        <div class="col-md-2"><strong>Llave Control:</strong> {{ historia.control_otr }}</div>
      </div>
      <div class="mb-2">
        <strong>Datos Generales:</strong>
        <span class="ml-2">{{ datosReferencia }}</span>
      </div>
      <div class="row mb-2">
        <div class="col-md-2"><strong>Fecha Emisión:</strong> {{ historia.fecha_emision | formatDate }}</div>
        <div class="col-md-2"><strong>Fecha Modif:</strong> {{ historia.fecha_actualiz | formatDate }}</div>
        <div class="col-md-2"><strong>Usuario:</strong> {{ historia.usu_descrip }}</div>
        <div class="col-md-2"><strong>Vigencia:</strong> {{ historia.vig_descrip }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-2"><strong>Imp Adeudo:</strong> {{ historia.importe_global | currency }}</div>
        <div class="col-md-2"><strong>Imp Rec:</strong> {{ historia.importe_recargo | currency }}</div>
        <div class="col-md-2"><strong>Imp Multa:</strong> {{ historia.importe_multa | currency }}</div>
        <div class="col-md-2"><strong>Imp Gastos:</strong> {{ historia.importe_gastos | currency }}</div>
        <div class="col-md-1"><strong>Zona:</strong> {{ historia.zona_apremio }}</div>
        <div class="col-md-2"><strong>% Multa:</strong> {{ historia.porcentaje_multa }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-2"><strong>Diligencia:</strong> {{ historia.diligencia }} - {{ historia.dil_descrip }}</div>
        <div class="col-md-2"><strong>Cve-Prac:</strong> {{ historia.clave_practicado }} - {{ historia.pra_descrip }}</div>
        <div class="col-md-2"><strong>Fecha Practicado:</strong> {{ historia.fecha_practicado | formatDate }}</div>
        <div class="col-md-2"><strong>Hora Practicado:</strong> {{ historia.hora_practicado | formatTime }}</div>
        <div class="col-md-2"><strong>Fecha Citatorio:</strong> {{ historia.fecha_citatorio | formatDate }}</div>
        <div class="col-md-2"><strong>Hora Citatorio:</strong> {{ historia.hora | formatTime }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-2"><strong>Ejecutor:</strong> {{ historia.ejecutor }}</div>
        <div class="col-md-3"><strong>Nombre:</strong> {{ historia.nombre_eje }}</div>
        <div class="col-md-2"><strong>Fecha Entrega 1:</strong> {{ historia.fecha_entrega1 | formatDate }}</div>
        <div class="col-md-2"><strong>Fecha Entrega 2:</strong> {{ historia.fecha_entrega2 | formatDate }}</div>
        <div class="col-md-1"><strong>Cve-Sec:</strong> {{ historia.clave_secuestro }} - {{ historia.sec_descrip }}</div>
        <div class="col-md-1"><strong>Cve-Rem:</strong> {{ historia.clave_remate }} - {{ historia.rem_descrip }}</div>
        <div class="col-md-2"><strong>Fecha Remate:</strong> {{ historia.fecha_remate | formatDate }}</div>
      </div>
      <div class="row mb-2">
        <div class="col-md-2"><strong>Fecha de Pago:</strong> {{ historia.fecha_pago | formatDate }}</div>
        <div class="col-md-2"><strong>Rec-Pag:</strong> {{ historia.recaudadora }}</div>
        <div class="col-md-2"><strong>Caja-Pag:</strong> {{ historia.caja }}</div>
        <div class="col-md-2"><strong>Operacion:</strong> {{ historia.operacion }}</div>
        <div class="col-md-2"><strong>Impte. Pag. Gastos:</strong> {{ historia.importe_pago | currency }}</div>
      </div>
      <div class="mb-2">
        <strong>Observaciones:</strong> {{ historia.observaciones }}
      </div>
      <h4 class="mt-4">Detalles</h4>
      <table class="table table-bordered table-sm">
        <thead>
          <tr>
            <th>Año</th>
            <th>Mes</th>
            <th>Importe</th>
            <th>Recargos</th>
            <th>Cantidad</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="detalle in detalles" :key="detalle.id_control">
            <td>{{ detalle.ayo }}</td>
            <td>{{ detalle.periodo }}</td>
            <td>{{ detalle.importe | currency }}</td>
            <td>{{ detalle.recargos | currency }}</td>
            <td>{{ detalle.cantidad | currency }}</td>
          </tr>
        </tbody>
      </table>
      <button class="btn btn-secondary mt-3" @click="goBack">Salir</button>
    </div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'ConsHisPage',
  data() {
    return {
      historia: null,
      detalles: [],
      datosReferencia: '',
      loading: false,
      error: null
    };
  },
  filters: {
    formatDate(val) {
      if (!val) return '';
      return new Date(val).toLocaleDateString();
    },
    formatTime(val) {
      if (!val) return '';
      let d = new Date(val);
      return d.toLocaleTimeString([], { hour: '2-digit', minute: '2-digit' });
    },
    currency(val) {
      if (val == null) return '';
      return Number(val).toLocaleString('es-MX', { style: 'currency', currency: 'MXN' });
    }
  },
  methods: {
    async fetchHistoria(control) {
      this.loading = true;
      this.error = null;
      try {
        // 1. Obtener historia principal
        let res = await axios.post('/api/execute', {
          eRequest: 'getConsHis',
          params: { control }
        });
        if (!res.data.eResponse.success || !res.data.eResponse.data.length) {
          throw new Error('No se encontró información para el control especificado.');
        }
        this.historia = res.data.eResponse.data[0];
        // 2. Obtener detalles
        let resDet = await axios.post('/api/execute', {
          eRequest: 'getConsHisDetails',
          params: { control_otr: this.historia.control_otr }
        });
        this.detalles = resDet.data.eResponse.data;
        // 3. Obtener referencia de datos (Mercado/Aseo)
        if (this.historia.modulo === 16) {
          let resAseo = await axios.post('/api/execute', {
            eRequest: 'getAseoReference',
            params: { contrato: this.historia.control_otr }
          });
          if (resAseo.data.eResponse.data && resAseo.data.eResponse.data.length) {
            let aseo = resAseo.data.eResponse.data[0];
            this.datosReferencia = `No. Contrato ${aseo.tipo_aseo}-${aseo.num_contrato}`;
          } else {
            this.datosReferencia = 'Registro de Aseo sin Referencia';
          }
        } else if (this.historia.modulo === 11) {
          let resMercado = await axios.post('/api/execute', {
            eRequest: 'getMercadoReference',
            params: { local: this.historia.control_otr }
          });
          if (resMercado.data.eResponse.data && resMercado.data.eResponse.data.length) {
            let m = resMercado.data.eResponse.data[0];
            this.datosReferencia = `Mercado No. ${m.num_mercado} Categoria ${m.categoria} Secc. ${m.seccion} Local ${m.local}-${m.letra_local}-${m.bloque}`;
          } else {
            this.datosReferencia = 'Registro de Mercado sin Referencia';
          }
        } else {
          this.datosReferencia = '';
        }
      } catch (err) {
        this.error = err.message || 'Error al cargar los datos';
      } finally {
        this.loading = false;
      }
    },
    goBack() {
      this.$router.back();
    }
  },
  mounted() {
    // Espera que la ruta tenga un parámetro :control
    const control = this.$route.params.control;
    if (control) {
      this.fetchHistoria(control);
    } else {
      this.error = 'Falta el parámetro control en la URL';
    }
  }
};
</script>

<style scoped>
.cons-his-page {
  background: #f8f9fa;
  padding: 2rem;
  border-radius: 8px;
}
.breadcrumb {
  background: none;
  padding: 0;
  margin-bottom: 1rem;
}
</style>
