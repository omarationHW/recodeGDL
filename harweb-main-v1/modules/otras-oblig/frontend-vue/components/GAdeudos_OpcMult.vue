<template>
  <div class="gadeudos-opcmult-page">
    <div class="breadcrumb">
      <router-link to="/">Inicio</router-link> /
      <span>Opción Múltiple de Adeudos</span>
    </div>
    <h2>{{ titulo }}</h2>
    <div class="panel panel-search">
      <label>{{ labelBusqueda }}</label>
      <div v-if="showNumExpN">
        <input v-model="numExpN" @keyup.enter="buscar" placeholder="Número de Expediente" maxlength="10" />
      </div>
      <div v-if="showLocalNum">
        <input v-model="localNum" @keyup.enter="focusLetra" placeholder="Número de Local" maxlength="3" />
        <input v-model="letra" @keyup.enter="buscar" placeholder="Letra" maxlength="2" />
      </div>
      <button @click="buscar">Buscar</button>
    </div>
    <div v-if="concesion" class="panel panel-concesion">
      <div class="row">
        <div><strong>Status:</strong> {{ concesion.statusregistro }}</div>
        <div><strong>Concesionario:</strong> {{ concesion.concesionario }}</div>
        <div><strong>Ubicación:</strong> {{ concesion.ubicacion }}</div>
        <div><strong>Nombre Comercial:</strong> {{ concesion.nomcomercial }}</div>
        <div><strong>Lugar:</strong> {{ concesion.lugar }}</div>
        <div><strong>Observaciones:</strong> {{ concesion.obs }}</div>
        <div><strong>Tipo:</strong> {{ concesion.unidades }}</div>
        <div><strong>Inicio Obligación:</strong> {{ concesion.fechainicio }}</div>
        <div><strong>Fin Obligación:</strong> {{ concesion.fechafin }}</div>
        <div><strong>Licencia:</strong> {{ concesion.licencia }}</div>
        <div><strong>Superficie:</strong> {{ concesion.superficie }}</div>
        <div><strong>Sector:</strong> {{ concesion.sector }}</div>
        <div><strong>Recaudadora:</strong> {{ concesion.recaudadora }}</div>
        <div><strong>Zona:</strong> {{ concesion.zona }}</div>
      </div>
    </div>
    <div v-if="adeudos && adeudos.length" class="panel panel-adeudos">
      <h3>Adeudos</h3>
      <table class="table table-striped">
        <thead>
          <tr>
            <th>Concepto</th>
            <th>Adeudo</th>
            <th>Recargo</th>
            <th>Multa</th>
            <th>Actualización</th>
            <th>Dcto. Adeudo</th>
            <th>Dcto. Rcgo.</th>
            <th>Dcto. Multa</th>
            <th>Seleccionar</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(row, idx) in adeudos" :key="idx">
            <td>{{ row.concepto }}</td>
            <td>{{ row.importe_pagar }}</td>
            <td>{{ row.recargos_pagar }}</td>
            <td>{{ row.multa_pagar }}</td>
            <td>{{ row.actualizacion_pagar }}</td>
            <td>{{ row.dscto_importe }}</td>
            <td>{{ row.dscto_recargos }}</td>
            <td>{{ row.dscto_multa }}</td>
            <td><input type="checkbox" v-model="row.selected" /></td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="concesion" class="panel panel-form">
      <div class="row">
        <label>Fecha de Pago:</label>
        <input type="date" v-model="fechaPagado" />
      </div>
      <div class="row">
        <label>Recaudadora:</label>
        <select v-model="idRecaudadora">
          <option v-for="r in recaudadoras" :key="r.id_rec" :value="r.id_rec">{{ r.id_rec }} - {{ r.recaudadora }}</option>
        </select>
        <label>Caja:</label>
        <select v-model="caja">
          <option v-for="c in cajas" :key="c.caja" :value="c.caja">{{ c.caja }}</option>
        </select>
      </div>
      <div class="row">
        <label>Consec. Oper.:</label>
        <input v-model="consecOper" maxlength="7" />
        <label>Folio Recibo:</label>
        <input v-model="folioRcbo" maxlength="15" />
      </div>
      <div class="row">
        <label>Opción:</label>
        <select v-model="opcion">
          <option v-for="o in opciones" :key="o.value" :value="o.value">{{ o.label }}</option>
        </select>
      </div>
      <div class="row">
        <button @click="ejecutarOpcion">Ejecutar</button>
        <button @click="verPagados" v-if="showPagados">Pagados</button>
      </div>
    </div>
    <div v-if="pagados && pagados.length" class="panel panel-pagados">
      <h3>Pagos Realizados</h3>
      <table class="table table-bordered">
        <thead>
          <tr>
            <th>Periodo</th>
            <th>Importe</th>
            <th>Recargo</th>
            <th>Fecha Pago</th>
            <th>Recaudadora</th>
            <th>Caja</th>
            <th>Operación</th>
            <th>Folio Recibo</th>
            <th>Usuario</th>
          </tr>
        </thead>
        <tbody>
          <tr v-for="(p, idx) in pagados" :key="idx">
            <td>{{ p.periodo }}</td>
            <td>{{ p.importe }}</td>
            <td>{{ p.recargo }}</td>
            <td>{{ p.fecha_hora_pago }}</td>
            <td>{{ p.id_recaudadora }}</td>
            <td>{{ p.caja }}</td>
            <td>{{ p.operacion }}</td>
            <td>{{ p.folio_recibo }}</td>
            <td>{{ p.usuario }}</td>
          </tr>
        </tbody>
      </table>
    </div>
    <div v-if="mensaje" class="alert alert-info">{{ mensaje }}</div>
  </div>
</template>

<script>
import axios from 'axios';
export default {
  name: 'GAdeudosOpcMultPage',
  data() {
    return {
      titulo: 'Opción Múltiple de Adeudos',
      labelBusqueda: 'BUSQUEDA POR:',
      numExpN: '',
      localNum: '',
      letra: '',
      showNumExpN: true,
      showLocalNum: false,
      concesion: null,
      adeudos: [],
      recaudadoras: [],
      cajas: [],
      fechaPagado: new Date().toISOString().substr(0, 10),
      idRecaudadora: '',
      caja: '',
      consecOper: '',
      folioRcbo: '',
      opcion: '',
      opciones: [],
      pagados: [],
      showPagados: false,
      mensaje: '',
      glo_Tabla: 3, // Por defecto, puede venir por props o route
      glo_Opc: 1 // Por defecto, puede venir por props o route
    };
  },
  created() {
    this.initPage();
  },
  methods: {
    async initPage() {
      // Cargar recaudadoras y cajas
      await this.loadRecaudadoras();
      await this.loadCajas();
      // Opciones según glo_Opc
      this.opciones = [
        { value: 'P', label: 'P - DAR DE PAGADO' },
        { value: 'S', label: 'S - CONDONAR' },
        { value: 'C', label: 'C - CANCELAR' },
        { value: 'R', label: 'R - PRESCRIBIR' }
      ].filter((o, idx) => idx + 1 === this.glo_Opc);
      this.opcion = this.opciones.length ? this.opciones[0].value : '';
      // Mostrar campos según tabla/opción
      if ([1,2,4,5].includes(this.glo_Tabla)) {
        this.showNumExpN = true;
        this.showLocalNum = false;
      } else if (this.glo_Tabla === 3) {
        this.showNumExpN = false;
        this.showLocalNum = true;
      }
    },
    async loadRecaudadoras() {
      const res = await axios.post('/api/execute', { action: 'getRecaudadoras' });
      this.recaudadoras = res.data.data || [];
      if (this.recaudadoras.length) this.idRecaudadora = this.recaudadoras[0].id_rec;
    },
    async loadCajas() {
      const res = await axios.post('/api/execute', { action: 'getCajas' });
      this.cajas = res.data.data || [];
      if (this.cajas.length) this.caja = this.cajas[0].caja;
    },
    focusLetra() {
      this.$refs.letra && this.$refs.letra.focus();
    },
    async buscar() {
      this.mensaje = '';
      let par_control = '';
      if (this.showNumExpN) {
        if (!this.numExpN) {
          this.mensaje = 'Falta el dato del NUMERO DE EXPEDIENTE, intentalo de nuevo';
          return;
        }
        // Obtener abreviatura
        const etiqRes = await axios.post('/api/execute', { action: 'getEtiquetas', params: { par_tab: this.glo_Tabla } });
        const abreviatura = etiqRes.data.data && etiqRes.data.data[0] ? etiqRes.data.data[0].abreviatura : '';
        par_control = abreviatura + this.numExpN;
      } else {
        if (!this.localNum) {
          this.mensaje = 'Falta el dato del NUMERO DE LOCAL, intentalo de nuevo';
          return;
        }
        par_control = this.localNum + (this.letra ? '-' + this.letra : '');
      }
      // Buscar concesion
      const res = await axios.post('/api/execute', { action: 'buscarConcesion', params: { par_tab: this.glo_Tabla, par_control } });
      if (!res.data.data || !res.data.data.length || res.data.data[0].status === -1) {
        this.mensaje = 'No existe REGISTRO ALGUNO con este dato, intentalo de nuevo';
        this.concesion = null;
        this.adeudos = [];
        return;
      }
      this.concesion = res.data.data[0];
      // Buscar adeudos
      await this.buscarAdeudos();
    },
    async buscarAdeudos() {
      if (!this.concesion) return;
      const year = new Date().getFullYear();
      const params = {
        par_tabla: this.glo_Tabla,
        par_id_datos: this.concesion.id_datos,
        par_aso: year,
        par_mes: 12
      };
      const res = await axios.post('/api/execute', { action: 'buscarAdeudos', params });
      this.adeudos = (res.data.data || []).map(a => ({ ...a, selected: false }));
      // Buscar pagados
      await this.buscarPagados();
    },
    async buscarPagados() {
      if (!this.concesion) return;
      const res = await axios.post('/api/execute', { action: 'buscarPagados', params: { p_Control: this.concesion.id_datos } });
      this.pagados = res.data.data || [];
      this.showPagados = this.pagados.length > 0;
    },
    async ejecutarOpcion() {
      if (!this.adeudos.some(a => a.selected)) {
        this.mensaje = 'No existen Adeudos Seleccionados, intenta con otro';
        return;
      }
      let ok = true;
      for (const adeudo of this.adeudos) {
        if (!adeudo.selected) continue;
        if ([ 'Multa', 'Descto. a Multa' ].includes(adeudo.concepto.trim())) continue;
        const params = {
          par_id_34_datos: this.concesion.id_datos,
          par_Axo: adeudo.axo,
          par_Mes: adeudo.mes,
          par_Fecha: this.fechaPagado,
          par_Id_Rec: this.idRecaudadora,
          par_Caja: this.caja,
          par_Consec: this.consecOper,
          par_Folio_rcbo: this.folioRcbo,
          par_tab: 'E',
          par_status: this.opcion,
          par_Opc: 'B',
          par_usuario: 'usuario_actual' // Reemplazar por usuario real
        };
        const res = await axios.post('/api/execute', { action: 'ejecutarOpcion', params });
        if (res.data.data && res.data.data[0] && res.data.data[0].status === 1) {
          this.mensaje = res.data.data[0].concepto_status;
        } else {
          this.mensaje = res.data.data && res.data.data[0] ? res.data.data[0].concepto_status : 'Error al ejecutar.';
          ok = false;
        }
      }
      if (ok) {
        await this.buscarAdeudos();
      }
    },
    async verPagados() {
      await this.buscarPagados();
    }
  }
};
</script>

<style scoped>
.gadeudos-opcmult-page {
  max-width: 1200px;
  margin: 0 auto;
  padding: 1rem;
}
.breadcrumb {
  margin-bottom: 1rem;
}
.panel {
  background: #f9f9f9;
  border: 1px solid #eee;
  padding: 1rem;
  margin-bottom: 1rem;
}
.row {
  display: flex;
  flex-wrap: wrap;
  gap: 1rem;
  margin-bottom: 0.5rem;
}
.table {
  width: 100%;
  border-collapse: collapse;
}
.table th, .table td {
  border: 1px solid #ccc;
  padding: 0.3rem 0.5rem;
}
.alert {
  margin-top: 1rem;
  color: #155724;
  background: #d4edda;
  border: 1px solid #c3e6cb;
  padding: 0.5rem;
}
</style>
