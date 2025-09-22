<template>
  <div class="adeudos-pag-page">
    <h1>DAR DE PAGADO ADEUDOS</h1>
    <form @submit.prevent="onVerAdeudos">
      <div class="form-row">
        <label>No. Contrato:</label>
        <input v-model="form.contrato" type="number" required maxlength="10" />
        <label>Tipo de Aseo:</label>
        <select v-model="form.tipo_aseo" required>
          <option v-for="ta in catalogos.tipo_aseo" :key="ta.ctrol_aseo" :value="ta.ctrol_aseo">
            {{ ta.ctrol_aseo }} - {{ ta.tipo_aseo }} - {{ ta.descripcion }}
          </option>
        </select>
      </div>
      <div class="form-row">
        <label>Año:</label>
        <input v-model="form.aso" type="number" required maxlength="4" />
        <label>Mes:</label>
        <select v-model="form.mes" required>
          <option v-for="m in meses" :key="m" :value="m">{{ m }}</option>
        </select>
      </div>
      <div class="form-row">
        <button type="submit">Ver Adeudos</button>
        <button type="button" @click="onCancelar">Salir</button>
      </div>
    </form>

    <div v-if="adeudos">
      <h2>Adeudos Encontrados</h2>
      <div class="adeudo-row" v-if="adeudos.cn">
        <input type="checkbox" v-model="form.pagar_cn" :disabled="adeudos.cn.pagado" />
        <span>Cuota Normal</span>
        <span>Cantidad: {{ adeudos.cn.exedencias }}</span>
        <span>Importe: <input v-model="form.importe_cn" :disabled="adeudos.cn.pagado" /></span>
        <span v-if="adeudos.cn.pagado">Pagado el {{ adeudos.cn.fecha_pago }} Rec {{ adeudos.cn.id_rec }} Caja {{ adeudos.cn.caja }}</span>
      </div>
      <div class="adeudo-row" v-if="adeudos.exe">
        <input type="checkbox" v-model="form.pagar_exe" :disabled="adeudos.exe.pagado" />
        <span>Excedencias</span>
        <span>Cantidad: {{ adeudos.exe.exedencias }}</span>
        <span>Importe: <input v-model="form.importe_exe" :disabled="adeudos.exe.pagado" /></span>
        <span v-if="adeudos.exe.pagado">Pagado el {{ adeudos.exe.fecha_pago }} Rec {{ adeudos.exe.id_rec }} Caja {{ adeudos.exe.caja }}</span>
      </div>
      <form @submit.prevent="onEjecutarPago">
        <div class="form-row">
          <label>Fecha de Pago:</label>
          <input v-model="form.fecha_pagado" type="date" required />
          <label>Recaudadora:</label>
          <select v-model="form.id_rec" required>
            <option v-for="r in catalogos.recaudadoras" :key="r.id_rec" :value="r.id_rec">{{ r.id_rec }} - {{ r.recaudadora }}</option>
          </select>
          <label>Caja:</label>
          <select v-model="form.caja" required>
            <option v-for="c in catalogos.cajas" :key="c.caja" :value="c.caja">{{ c.caja }}</option>
          </select>
        </div>
        <div class="form-row">
          <label>Consec. Operación:</label>
          <input v-model="form.consec_oper" type="number" required />
          <label>Folio Recibo:</label>
          <input v-model="form.folio_rcbo" required />
        </div>
        <div class="form-row">
          <button type="submit">Ejecutar Pago</button>
        </div>
      </form>
    </div>
    <div v-if="message" class="message" :class="{ error: !success }">{{ message }}</div>
  </div>
</template>

<script>
export default {
  name: 'AdeudosPagPage',
  data() {
    return {
      form: {
        contrato: '',
        tipo_aseo: '',
        aso: '',
        mes: '01',
        pagar_cn: false,
        pagar_exe: false,
        importe_cn: '',
        importe_exe: '',
        fecha_pagado: '',
        id_rec: '',
        caja: '',
        consec_oper: '',
        folio_rcbo: ''
      },
      catalogos: {
        tipo_aseo: [],
        recaudadoras: [],
        cajas: []
      },
      meses: [
        '01','02','03','04','05','06','07','08','09','10','11','12'
      ],
      adeudos: null,
      message: '',
      success: true
    }
  },
  created() {
    this.cargarCatalogos();
  },
  methods: {
    async cargarCatalogos() {
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'cargar_catalogos' } })
      });
      const data = await res.json();
      if (data.eResponse.success) {
        this.catalogos = data.eResponse.data;
        if (this.catalogos.tipo_aseo.length > 0) {
          this.form.tipo_aseo = this.catalogos.tipo_aseo[0].ctrol_aseo;
        }
        if (this.catalogos.recaudadoras.length > 0) {
          this.form.id_rec = this.catalogos.recaudadoras[0].id_rec;
        }
        if (this.catalogos.cajas.length > 0) {
          this.form.caja = this.catalogos.cajas[0].caja;
        }
      }
    },
    async onVerAdeudos() {
      this.message = '';
      this.adeudos = null;
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'ver_adeudos', params: {
          contrato: this.form.contrato,
          tipo_aseo: this.form.tipo_aseo,
          aso: this.form.aso,
          mes: this.form.mes
        }}})
      });
      const data = await res.json();
      if (data.eResponse.success) {
        // Mapear datos para mostrar en la UI
        const adeudos = { cn: null, exe: null };
        data.eResponse.data.forEach(row => {
          if (row.tipo_operacion === 'CN') {
            adeudos.cn = {
              ...row,
              pagado: row.status_vigencia === 'P',
              fecha_pago: row.fecha_hora_pago,
              id_rec: row.id_rec,
              caja: row.caja
            };
            this.form.importe_cn = row.importe;
          }
          if (row.tipo_operacion === 'EXE') {
            adeudos.exe = {
              ...row,
              pagado: row.status_vigencia === 'P',
              fecha_pago: row.fecha_hora_pago,
              id_rec: row.id_rec,
              caja: row.caja
            };
            this.form.importe_exe = row.importe;
          }
        });
        this.adeudos = adeudos;
      } else {
        this.message = data.eResponse.message;
        this.success = false;
      }
    },
    async onEjecutarPago() {
      this.message = '';
      const res = await fetch('/api/execute', {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify({ eRequest: { action: 'ejecutar_pago', params: {
          contrato: this.form.contrato,
          tipo_aseo: this.form.tipo_aseo,
          aso: this.form.aso,
          mes: this.form.mes,
          consec_oper: this.form.consec_oper,
          folio_rcbo: this.form.folio_rcbo,
          fecha_pagado: this.form.fecha_pagado,
          id_rec: this.form.id_rec,
          caja: this.form.caja,
          usuario_id: 1, // TODO: obtener usuario logueado
          pagar_cn: this.form.pagar_cn,
          pagar_exe: this.form.pagar_exe,
          importe_cn: this.form.importe_cn,
          importe_exe: this.form.importe_exe
        }}})
      });
      const data = await res.json();
      this.message = data.eResponse.message;
      this.success = data.eResponse.success;
      if (data.eResponse.success) {
        this.adeudos = null;
      }
    },
    onCancelar() {
      this.$router.push('/');
    }
  }
}
</script>

<style scoped>
.adeudos-pag-page {
  max-width: 700px;
  margin: 0 auto;
  background: #fff;
  padding: 2rem;
  border-radius: 8px;
}
.form-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 1rem;
}
.adeudo-row {
  display: flex;
  align-items: center;
  gap: 1rem;
  margin-bottom: 0.5rem;
}
.message {
  margin-top: 1rem;
  padding: 1rem;
  border-radius: 4px;
  background: #e0ffe0;
  color: #1a4d1a;
}
.message.error {
  background: #ffe0e0;
  color: #a00;
}
</style>
